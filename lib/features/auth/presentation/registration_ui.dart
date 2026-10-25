import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';

class FakeUserRepository implements UserRepository {
  const FakeUserRepository();

  @override
  Future<void> registerUser(User user) async {
    await Future.delayed(const Duration(seconds: 1)); // fake network delay
  }
}

class RegistrationUi extends StatefulWidget {
  final UserRepository repo;
  const RegistrationUi({super.key, required this.repo});
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
    debugPrint('registerClicked');
    if (!formKey.currentState!.validate()) return;
    debugPrint('2: valid');
    final User user = User(
      nickname: nicknameController.text,
      password: passwordController.text,
      active: true,
      verified: false,
      email: emailController.text,
    );
    debugPrint('3: user built');
    try {
      await widget.repo.registerUser(user);
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Return button
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: returnClicked,
                  ),
                ),
              ),

              // Title
              const Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Create an       account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),

              // Form
              Expanded(
                flex: 2,
                child: Form(
                  key: formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nicknameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Nickname',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Color(0xFFE6E0E9),
                              filled: true,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Color(0xFFE6E0E9),
                              filled: true,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Color(0xFFE6E0E9),
                              filled: true,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: repeatPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Repeat Password',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Color(0xFFE6E0E9),
                              filled: true,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            validator: (v) => v != passwordController.text
                                ? 'Passwords do not match'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Register button space
              Expanded(
                flex: 1,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),
                      backgroundColor: const Color(0xFF6750A4),
                    ),
                    onPressed: registerClicked,
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Empty space
              const Expanded(flex: 1, child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
