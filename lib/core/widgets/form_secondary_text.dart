import 'package:flutter/cupertino.dart';

class FormSecondaryText extends StatelessWidget {
  const FormSecondaryText(this._text, {super.key});

  final String _text;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    );
  }
}
