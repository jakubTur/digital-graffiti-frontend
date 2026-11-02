import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton(this.text, this.onPressed, this.color, {super.key});

  final String text;

  final void Function() onPressed;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
