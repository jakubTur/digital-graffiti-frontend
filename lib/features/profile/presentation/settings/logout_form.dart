import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/form_main_text.dart';
import '../../../../core/widgets/screen_header.dart';

class LogoutForm extends StatelessWidget {
  const LogoutForm({super.key, required this.authStorage});

  final AuthStorage authStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(alignment: Alignment.topRight, child: ScreenHeader()),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 80,
                  children: [
                    FormMainText(
                      text: 'Are you sure you want to log out?',
                      fontWeight: FontWeight.w800,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Expanded(
                          child: CustomButton(
                            text: 'Yes',
                            onPressed: () {
                              authStorage.clear();
                              context.go("/");
                            },
                            backgroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          child: CustomButton(
                            text: 'No',
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go("/map");
                              }
                            },
                            backgroundColor: Colors.red,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
