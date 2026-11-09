import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/form_main_text.dart';
import '../../../../core/widgets/form_secondary_text.dart';
import '../../../../core/widgets/screen_header.dart';

class ChangeEmailForm extends StatefulWidget {
  const ChangeEmailForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChangeEmailFormState();
  }
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  final TextEditingController _oldEmailController = TextEditingController();

  final TextEditingController _newEmailController = TextEditingController();

  final TextEditingController _repeatEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _emailError;

  @override
  void dispose() {
    _oldEmailController.dispose();
    _newEmailController.dispose();
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
                Align(alignment: Alignment.topRight, child: ScreenHeader()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 30,
                  children: [
                    FormMainText('Change email'),
                    FormSecondaryText(
                      'Enter your current email and your new email address',
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 30,
                        children: [
                          CustomTextField(
                            controller: _oldEmailController,
                            labelText: 'Old email',
                            errorText: _emailError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your old email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _newEmailController,
                            labelText: 'New email',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a new email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              if (v == _oldEmailController.text) {
                                return 'New email must be different';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _repeatEmailController,
                            labelText: 'Repeat new email',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please repeat your new email';
                              }
                              if (v != _newEmailController.text) {
                                return 'Emails do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'Change email',
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          _emailError = null;
                        });

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          String? email = prefs.getString("email");
                          if (email != _oldEmailController.text) {
                            throw Exception();
                          }

                          ///TODO: update the email somehow

                          if (context.mounted) {
                            context.go('/password-changed');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _emailError = 'Incorrect old email';
                          });
                        }
                      },
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
