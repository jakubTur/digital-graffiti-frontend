import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/form_main_text.dart';
import '../../../core/widgets/screen_header.dart';
import '../domain/repositories/user_repository.dart';

class ForgotPasswordForm extends StatefulWidget {
  final UserRepository repo;
  const ForgotPasswordForm({super.key, required this.repo});

  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordForm();
  }
}

class _ForgetPasswordForm extends State<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _repeatEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _emailError;

  void _onPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailError = null;
    });
    try {
      await widget.repo.resetPassword(_emailController.text);

      if (context.mounted) {
        context.go('/forgot-password-success');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = 'Failed to reset password';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _repeatEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: ScreenHeader(onBackPressed: () {
                    context.go("/");
                  }),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 30,
                  children: [
                    FormMainText(
                      'Enter your e-mail address to receive your password reset link',
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 30,
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Current email',
                            errorText: _emailError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your current email';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _repeatEmailController,
                            labelText: 'Repeat email',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please repeat your email';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Please enter a valid email address';
                              }
                              if (_emailController.text !=
                                  _repeatEmailController.text) {
                                return "Emails do not match";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'Reset password',
                      onPressed: _onPressed,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
