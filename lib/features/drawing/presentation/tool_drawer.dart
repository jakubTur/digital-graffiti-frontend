import 'package:flutter/material.dart';

class ToolDrawer extends StatelessWidget {
  final Widget? child;

  const ToolDrawer({super.key, this.child});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    layoutBuilder: (current, previous) => Stack(
      alignment: Alignment.bottomCenter,
      children: [...previous, ?current],
    ),
    transitionBuilder: (child, animation) => SizeTransition(
      sizeFactor: animation,
      alignment: Alignment.topCenter,
      child: Material(
        elevation: 4,
        color: Colors.deepPurple.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
    child: child,
  );
}
