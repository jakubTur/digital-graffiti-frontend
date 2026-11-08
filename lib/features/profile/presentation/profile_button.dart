import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton(this._text, this._onPressed, this._color, {super.key});

  final String _text;

  final void Function() _onPressed;

  final Color _color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        backgroundColor: _color,
      ),
      onPressed: _onPressed,
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
