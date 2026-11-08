import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/screen_header.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/form_main_text.dart';
import '../../../auth/data/models/login_request.dart';
import '../../../auth/domain/repositories/user_repository.dart';

class DeleteAccountForm extends StatefulWidget {
  const DeleteAccountForm(this._authStorage, this._userRepository, {super.key});

  final AuthStorage _authStorage;

  final UserRepository _userRepository;

  @override
  State<StatefulWidget> createState() {
    return _DeleteAccountState();
  }
}

class _DeleteAccountState extends State<DeleteAccountForm> {
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Align(alignment: Alignment.topRight, child: ScreenHeader()),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 30,
                      children: [
                        FormMainText(text: 'Are you sure?'),
                        FormSecondaryText(
                          'Your account and all related data will be deleted',
                        ),
                        FormSecondaryText('Enter your password to confirm'),
                        Form(
                          key: _formKey,
                          child: Column(
                            spacing: 30,
                            children: [
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                obscureText: true,
                                errorText: _passwordError,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                controller: _repeatPasswordController,
                                obscureText: true,
                                labelText: 'Repeat Password',
                                errorText: _passwordError,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please repeat your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        CustomButton(
                          text: 'Delete account',
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() {
                              _passwordError = null;
                            });
                            try {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              String? email = prefs.getString("email");
                              final _ = await widget._userRepository.login(
                                LoginRequest(
                                  email: email ?? "",
                                  password: _passwordController.text,
                                ),
                              );
                              int userId =
                                  await widget._authStorage.readId() ?? 0;
                              await widget._userRepository.deleteUser(userId);
                              widget._authStorage.clear();
                              if (context.mounted) {
                                context.go('/');
                              }
                            } catch (e) {
                              setState(() {
                                _passwordError = "Incorrect password";
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
            );
          },
        ),
      ),
    );
  }
}
