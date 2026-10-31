import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton(this.text, this.onPressed, this.color, {super.key});

  final String text;

  final void Function() onPressed;

  final double width = 214;

  final double height = 70;

  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(214, 70),
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
