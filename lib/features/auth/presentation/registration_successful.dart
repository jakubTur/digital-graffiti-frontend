import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrationSuccessful extends StatelessWidget {
  const RegistrationSuccessful({super.key});

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
                              'Account created!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'Please verify your account by clicking the link sent to your e-mail address',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(214, 70),
                            backgroundColor: const Color(0xFF6750A4),
                          ),
                          onPressed: () {
                            context.go('/');
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
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
