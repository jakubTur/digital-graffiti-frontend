import 'package:flutter/material.dart';

class PopupText extends StatelessWidget {
  final String text;

  const PopupText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
