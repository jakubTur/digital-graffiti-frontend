import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';

class RegistrationUi extends StatefulWidget {
  final UserRepository repo;
  final AuthStorage authStorage;
  const RegistrationUi({
    super.key,
    required this.repo,
    required this.authStorage,
  });
  @override
  State<RegistrationUi> createState() => RegistrationUiState();
}

class RegistrationUiState extends State<RegistrationUi> {
  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  void returnClicked() {
    Navigator.of(context).pop();
  }

  Future<void> registerClicked() async {
    if (!formKey.currentState!.validate()) return;
    widget.authStorage.clear();
    final User user = User(
      nickname: nicknameController.text,
      password: passwordController.text,
      active: true,
      verified: false,
      email: emailController.text,
    );
    try {
      await widget.repo.registerUser(user);
      if (!mounted) return;
      context.push('/registration_successful');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Return button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            iconSize: 50,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: returnClicked,
                          ),
                        ),
                        const Spacer(),

                        // Title
                        const Column(
                          children: [
                            Text(
                              'Create an',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Spacer(),

                        // Form
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextField(
                                controller: nicknameController,
                                labelText: 'Nickname',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter a nickname';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: emailController,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter an email';
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
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: passwordController,
                                labelText: 'Password',
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
                                    RegExp(
                                      r'[!@#$%^&*(),.?":{}|<>\-_=+\\|/[\]~`]',
                                    ),
                                  )) {
                                    return 'Password must contain at least one special character';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: repeatPasswordController,
                                labelText: 'Repeat Password',
                                obscureText: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please repeat your password';
                                  }
                                  if (v != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Spacer(),

                        // Register button space
                        Center(
                          child: CustomButton(
                            text: 'Register',
                            width: 200,
                            height: 50,
                            fontSize: 18,
                            onPressed: registerClicked,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
