import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/form_main_text.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:go_router/go_router.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
    this._primaryMessage,
    this._secondaryMessage, {
    super.key,
  });

  final String _primaryMessage;

  final String? _secondaryMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  context.go("/");
                },
                icon: Icon(Icons.exit_to_app),
              ),
            ),
            Align(
              child: Column(
                children: [
                  FormMainText(_primaryMessage),
                  if (_secondaryMessage != null)
                    FormSecondaryText(_secondaryMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
