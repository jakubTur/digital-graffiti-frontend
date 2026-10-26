import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';

@Preview(name: 'Login - phone', size: Size(390, 844))
Widget loginPreview() => const LoginUi();

class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<StatefulWidget> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _credentialsError;
  bool _passwordHidden = true;
  bool _rememberUser = false;

  Future<void> _handleLogin() async {
    //TODO: integrate with backend

    //TODO: update _credentialsError if login failed
    context.go('/map'); // this routes to login screen

    setState(() {
      _credentialsError = "E-mail or password is incorrect";
    });

    if (_rememberUser) {
      //TODO: implement remember me functionality
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
              // Title
              const Expanded(flex: 1, child: SizedBox.shrink()),
              const Expanded(
                flex: 2,
                child: Center(
                  child: Column(
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
                ),
              ),

              // Form
              Expanded(
                flex: 4,
                child: Form(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Color(0xFFE6E0E9),
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
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            obscureText: _passwordHidden,
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.black),
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
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                //TODO: redirect to forgot password form
                              },
                              child: Text(
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
                                Text(
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
                          const SizedBox(height: 12),
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
                      fixedSize: const Size(214, 70),
                      backgroundColor: const Color(0xFF6750A4),
                    ),
                    onPressed: () {
                      _handleLogin();
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox.shrink()),

              // Registration option space
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
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
                      child: Text(
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
