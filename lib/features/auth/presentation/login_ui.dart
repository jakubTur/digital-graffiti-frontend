import 'package:flutter/material.dart';
import 'package:frontend/features/notifications/data/services/push_notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/auth_storage.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/form_main_text.dart';
import '../data/models/login_request.dart';
import '../domain/repositories/user_repository.dart';

class LoginUi extends StatefulWidget {
  final UserRepository repo;
  final AuthStorage authStorage;
  final PushNotificationService notificationService;
  const LoginUi({super.key, required this.repo, required this.authStorage, required this.notificationService});

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
      try {
        await widget.notificationService.registerCurrentToken();
      } catch (error, stackTrace) {
        debugPrint('FCM token registration failed: $error');
        debugPrint('Stack trace: $stackTrace');
      }

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
                            FormMainText(
                              'Welcome to Digital Graffiti!',
                              fontWeight: FontWeight.w900,
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
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                hasError: _credentialsError != null,
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
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                obscureText: _passwordHidden,
                                errorText: _credentialsError,
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
                          child: CustomButton(
                            text: 'Log in',
                            width: 214,
                            height: 70,
                            fontSize: 18,
                            onPressed: _handleLogin,
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
