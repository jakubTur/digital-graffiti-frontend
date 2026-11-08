import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageBytes,
    this.size = 120.0,
    this.backgroundColor,
    this.iconColor = Colors.deepPurple,
  });

  final Uint8List? imageBytes;
  final double size;
  final Color? backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? Colors.deepPurple.shade50,
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Icon(Icons.person, size: size, color: iconColor),
      ),
    );
  }
}
