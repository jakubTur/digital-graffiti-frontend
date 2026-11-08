import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';

class LogoutForm extends StatelessWidget {
  const LogoutForm({super.key, required this.authStorage});

  final AuthStorage authStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 80,
          children: [
            Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Expanded(
                  child: ProfileButton('Yes', () {
                    authStorage.clear();
                    context.go("/");
                  }, Colors.green),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: ProfileButton('No', () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go("/map");
                    }
                  }, Colors.red),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
