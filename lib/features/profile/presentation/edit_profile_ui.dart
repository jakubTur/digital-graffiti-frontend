import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';

class EditProfileUi extends StatelessWidget {
  const EditProfileUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [ProfileButton("jajo", () {}, Colors.deepPurple)]);
  }
}
