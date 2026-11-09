import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/form_main_text.dart';
import '../../../core/widgets/form_secondary_text.dart';

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
                            FormMainText(
                              'Account created!',
                              fontWeight: FontWeight.w900,
                            ),
                            FormSecondaryText(
                              'Please verify your account by clicking the link sent to your e-mail address',
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: CustomButton(
                            text: 'Log in',
                            width: 214,
                            height: 70,
                            fontSize: 18,
                            onPressed: () {
                              context.go('/');
                            },
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
