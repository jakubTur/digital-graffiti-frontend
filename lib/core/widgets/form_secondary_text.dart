import 'package:flutter/material.dart';

class FormSecondaryText extends StatelessWidget {
  const FormSecondaryText(
    this._text, {
    this._fontSize = 20,
    super.key,
    this.color = Colors.black,
  });

  final String _text;

  final double _fontSize;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: _fontSize, color: color),
    );
  }
}
