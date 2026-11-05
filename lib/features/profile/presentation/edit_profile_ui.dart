import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';

class EditProfileUi extends StatelessWidget {
  const EditProfileUi({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ProfileButton("jajo", () {}, Colors.deepPurple)],
      ),
    );
  }
}
