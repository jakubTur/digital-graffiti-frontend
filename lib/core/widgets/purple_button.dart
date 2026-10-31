import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  const PurpleButton(this.text, this.onPressed, {super.key});

  final String text;

  final void Function() onPressed;

  final double width = 214;

  final double height = 70;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(214, 70),
        backgroundColor: const Color(0xFF6750A4),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
