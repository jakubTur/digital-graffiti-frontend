import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 30,
            children: [
              Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                'Your account and all related data will be deleted',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Enter your password to confirm',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Form(
                key: _formKey,
                child: Column(
                  spacing: 30,
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        fillColor: const Color(0xFFE6E0E9),
                        filled: true,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? Colors.red
                                : Colors.deepPurple,
                          ),
                        ),
                        errorText: _passwordError,
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _repeatPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Repeat Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        fillColor: const Color(0xFFE6E0E9),
                        filled: true,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? Colors.red
                                : Colors.deepPurple,
                          ),
                        ),
                        errorText: _passwordError,
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
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

              ProfileButton('Delete account', () async {
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
                      password: _passwordController.text,
                    ),
                  );
                  int userId = await widget._authStorage.readId() ?? 0;
                  widget._userRepository.deleteUser(userId);
                  widget._authStorage.clear();
                  if (context.mounted) {
                    context.go('/');
                  }
                } catch (e) {
                  setState(() {
                    _passwordError = "Incorrect password";
                  });
                }
              }, Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
