import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageBytes,
    this.size = 120.0,
    this.backgroundColor,
    this.iconColor = Colors.deepPurple,
    this.imageUrl,
  });

  final Uint8List? imageBytes;
  final double size;
  final Color? backgroundColor;
  final Color iconColor;
  final String? imageUrl;

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
            : imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image)),
              )
            : Icon(Icons.person, size: size, color: iconColor),
      ),
    );
  }
}
