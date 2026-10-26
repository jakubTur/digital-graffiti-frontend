import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/paint_canvas.dart';
import 'package:frontend/features/drawing/presentation/paint_ui.dart';

// Composes background, canvas and UI.
class PaintScreen extends StatelessWidget {
  final String? imagePath;

  const PaintScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (imagePath != null && imagePath!.isNotEmpty)
            Positioned.fill(
              child: Image.file(File(imagePath!), fit: BoxFit.cover),
            )
          else
            Positioned.fill(child: Container(color: Colors.green[100])),
          const PaintCanvas(),
          const PaintUi(),
        ],
      ),
    );
  }
}
