import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/screen_header.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/custom_button.dart';

class AccountSettings extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AccountSettings({this.onBackPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        spacing: 40,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScreenHeader(title: 'Settings', onBackPressed: onBackPressed),
          CustomButton(
            text: 'Change password',
            onPressed: () {
              context.push('/change-password');
            },
            backgroundColor: Colors.deepPurple,
          ),
          CustomButton(
            text: 'Change email',
            onPressed: () {
              context.push('/change-email');
            },
            backgroundColor: Colors.deepPurple,
          ),
          CustomButton(
            text: 'Log out',
            onPressed: () {
              context.push('/logout');
            },
            backgroundColor: Colors.deepPurple,
          ),
          CustomButton(
            text: 'Delete account',
            onPressed: () {
              context.push('/delete-account');
            },
            backgroundColor: Colors.deepPurple,
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
