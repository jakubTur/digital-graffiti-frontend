import 'package:flutter/material.dart';

class FormMainText extends StatelessWidget {
  const FormMainText(
    this._text, {
    this._fontSize = 40,
    this._fontWeight = FontWeight.w900,
    super.key,
  });

  final String _text;

  final double _fontSize;

  final FontWeight _fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        color: Colors.black,
        fontFamily: 'Inter',
      ),
    );
  }
}
