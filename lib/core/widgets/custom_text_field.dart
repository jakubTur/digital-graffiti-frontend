import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.suffixIcon,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.hasError = false,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isErrorState = hasError || errorText != null;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        fillColor: const Color(0xFFE6E0E9),
        filled: true,
        suffixIcon: suffixIcon,
        errorText: errorText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isErrorState ? Colors.red : Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isErrorState ? Colors.red : Colors.deepPurple,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }
}
