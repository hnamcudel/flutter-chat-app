import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _registerButton(),
            if (!isLoading) _switchStatus(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        children: [
          Text(
            "Register User",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Register for a new account!",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.03,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            _pfpSelectionFiled(),
            const SizedBox(
              height: 20,
            ),
            CustomFormField(
              hintText: "Name",
              validationRegEx: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomFormField(
              hintText: "Email",
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomFormField(
              hintText: "Password",
              obscureText: true,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      // color: Theme.of(context).colorScheme.primary,
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        try {
          if ((_registerFormKey.currentState?.validate() ?? false)) {
            _registerFormKey.currentState?.save();
            bool result = await _authService.signup(email!, password!);
            if (result) {
              String? pfpURL = await _storageService.uploadUserPfp(
                file: selectedImage!,
                uid: _authService.user!.uid,
              );
              if (pfpURL != null) {
                await _databaseService.createUserProfile(
                  userProfile: UserProfile(
                    uid: _authService.user!.uid,
                    name: name,
                    pfpURL: pfpURL,
                  ),
                );
                _alertService.showToast(
                  text: "User registerded successfully",
                  icon: Icons.check,
                );
                _navigationService.goBack();
                _navigationService.pushReplacementNamed("/home");
              } else {
                throw Exception("Unable to upload user profile picture");
              }
            } else {
              throw Exception("Unable to register user");
            }
          }
        } catch (e) {
          _alertService.showToast(
            text: "Failed to register, Please try again!",
            icon: Icons.error,
          );
        }
        setState(() {
          isLoading = false;
        });
      },
      child: const Text(
        "Register",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _pfpSelectionFiled() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromCamera();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _switchStatus() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Already have an account ? ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: 'Sign in',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _navigationService.goBack();
              },
          ),
        ],
      ),
    );
  }
}
