import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.hintText,
    required this.validationRegEx,
    required this.onSaved,
    this.obscureText = false,
  });

  final String hintText;
  final RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      obscureText: obscureText,
      validator: (value) {
        if (value != null && validationRegEx.hasMatch(value)) {
          return null;
        }
        return "Enter a valid ${hintText.toLowerCase()}";
      },
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
