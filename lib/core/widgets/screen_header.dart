import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    this.title,
    this.onBackPressed,
    this.titleStyle,
    this.iconSize = 40.0,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final TextStyle? titleStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title != null)
          Text(
            title!,
            style:
                titleStyle ??
                const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
        const Spacer(),
        IconButton(
          onPressed:
              onBackPressed ??
              () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/map');
                }
              },
          iconSize: iconSize,
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ],
    );
  }
}
