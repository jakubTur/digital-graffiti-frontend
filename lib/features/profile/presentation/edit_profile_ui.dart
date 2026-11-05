import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';

class EditProfileUi extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const EditProfileUi({this.onBackPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 30,
        children: [
          Row(
            children: [
              Text(
                'Edit profile',
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
          Row(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 120, color: Colors.deepPurple),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.draw),
                iconSize: 60,
                color: Colors.black,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.photo_camera),
                iconSize: 60,
                color: Colors.black,
              ),
            ],
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Nickname',
              labelStyle: const TextStyle(color: Colors.black),
              fillColor: const Color(0xFFE6E0E9),
              filled: true,
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.name,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Bio',
              labelStyle: const TextStyle(color: Colors.black),
              fillColor: const Color(0xFFE6E0E9),
              filled: true,
            ),
          ),
          ProfileButton('Save changes', () {}, Colors.green),
        ],
      ),
    );
  }
}
