import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';

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
          Row(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/map');
                  }
                },
                iconSize: 60,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ],
          ),
          ProfileButton('Change password', () {}, Colors.deepPurple),
          ProfileButton('Change email', () {}, Colors.deepPurple),
          ProfileButton('Log out', () {}, Colors.deepPurple),
          ProfileButton('Delete account', () {}, Colors.deepPurple),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
