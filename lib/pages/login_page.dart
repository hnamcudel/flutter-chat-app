import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _buildUI(),
      ),
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
            _loginForm(),
            _loginButton(),
            _switchStatus(),
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
            "Hi, Welcome back!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Hello again, you've been missed!",
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

  Widget _loginForm() {
    return Container(
      // height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.03,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            CustomFormField(
              hintText: 'Email',
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
              hintText: 'Password',
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
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

  Widget _loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      onPressed: () async {
        if (_loginFormKey.currentState?.validate() ?? false) {
          _loginFormKey.currentState?.save();
          bool result = await _authService.login(email!, password!);
          if (result) {
            _navigationService.pushReplacementNamed("/home");
          } else {
            _alertService.showToast(
              text: "Failed to login, please try again!",
              icon: Icons.error,
            );
          }
        }
      },
      child: const Text(
        "Sign in",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _switchStatus() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Don\'t have an account ? ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: 'Sign up',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () {
              _navigationService.pushNamed("/register");
            },
          ),
        ],
      ),
    );
  }
}
