import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Registration - phone', size: Size(390, 844))
Widget registrationPreview() => const RegistrationUi();

class RegistrationUi extends StatelessWidget {
  const RegistrationUi({super.key});

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
                    onPressed: () {},
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
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black, fontFamily: 'Inter'),
                  ),
                ),
              ),

              // Form
              Expanded(
                flex: 2,
                child: Form(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
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
                    onPressed: () {},
                    child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, color: Colors.white)
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