import 'package:flutter/cupertino.dart';

class FormSecondaryText extends StatelessWidget {
  const FormSecondaryText(this._text, {this._fontSize = 20, super.key});

  final String _text;

  final double _fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: _fontSize),
    );
  }
}
