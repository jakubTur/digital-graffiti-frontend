import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/core/widgets/form_main_text.dart';
import 'package:frontend/features/auth/data/models/credential_request.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/form_secondary_text.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../auth/data/models/login_request.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm(
    this._authStorage,
    this._userRepository, {
    super.key,
  });

  final AuthStorage _authStorage;
  final UserRepository _userRepository;

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordFormState();
  }
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _oldPasswordController = TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _passwordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
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
                    FormMainText('Change password'),
                    FormSecondaryText(
                      'Enter your current password and choose a new one',
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 30,
                        children: [
                          CustomTextField(
                            controller: _oldPasswordController,
                            labelText: 'Old password',
                            obscureText: true,
                            errorText: _passwordError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your old password';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _newPasswordController,
                            labelText: 'New password',
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              if (!v.contains(RegExp(r'[A-Z]'))) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              if (!v.contains(RegExp(r'[a-z]'))) {
                                return 'Password must contain at least one lowercase letter';
                              }
                              if (!v.contains(RegExp(r'[0-9]'))) {
                                return 'Password must contain at least one number';
                              }
                              if (!v.contains(
                                RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\\|/[\]~`]'),
                              )) {
                                return 'Password must contain at least one special character';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _repeatPasswordController,
                            labelText: 'Repeat new password',
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please repeat your new password';
                              }
                              if (v != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'Change password',
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          _passwordError = null;
                        });

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          String? email = prefs.getString("email");
                          final _ = await widget._userRepository.login(
                            LoginRequest(
                              email: email ?? "",
                              password: _oldPasswordController.text,
                            ),
                          );

                          int? id = await widget._authStorage.readUserId();
                          if (id == null) {
                            throw Exception('User ID not found');
                          }
                          CredentialRequest request = CredentialRequest(
                            email: email ?? "",
                            password: _newPasswordController.text,
                          );
                          await widget._userRepository.updatePassword(
                            id,
                            request,
                          );

                          if (context.mounted) {
                            context.go('/password-changed');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _passwordError = 'Incorrect old password';
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
