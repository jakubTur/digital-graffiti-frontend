import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/auth_storage.dart';
import '../data/models/login_request.dart';
import '../domain/repositories/user_repository.dart';

class LoginUi extends StatefulWidget {
  final UserRepository repo;
  final AuthStorage authStorage;
  const LoginUi({super.key, required this.repo, required this.authStorage});

  @override
  State<StatefulWidget> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _credentialsError;
  bool _passwordHidden = true;
  bool _rememberUser = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _credentialsError = null;
    });

    try {
      final response = await widget.repo.login(
        LoginRequest(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
      await widget.authStorage.saveLogin(response);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _rememberUser);
      if (!mounted) return;
      context.go('/map');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _credentialsError = 'Email or password is incorrect';
      });
    }
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
                        const Spacer(),
                        // Title
                        const Column(
                          children: [
                            Text(
                              'Welcome to',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'Digital Graffiti!',
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
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  fillColor: const Color(0xFFE6E0E9),
                                  filled: true,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _credentialsError != null
                                          ? Colors.red
                                          : Colors.deepPurple,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _credentialsError != null
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                obscureText: _passwordHidden,
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  fillColor: const Color(0xFFE6E0E9),
                                  filled: true,
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordHidden
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordHidden = !_passwordHidden;
                                      });
                                    },
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  errorText: _credentialsError,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    //TODO: redirect to forgot password form
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.deepPurple,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberUser,
                                      onChanged: (rememberUser) {
                                        setState(() {
                                          _rememberUser = rememberUser ?? false;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Remember me',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Spacer(),

                        // Log in button space
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(214, 70),
                              backgroundColor: const Color(0xFF6750A4),
                            ),
                            onPressed: () {
                              _handleLogin();
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Spacer(),

                        // Registration option space
                        Column(
                          children: [
                            const Text(
                              "Don't have an account?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/register');
                              },
                              child: const Text(
                                'Create an account',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.deepPurple,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
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
