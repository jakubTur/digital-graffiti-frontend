import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/paint_canvas.dart';
import 'package:frontend/features/drawing/presentation/paint_ui.dart';
import 'package:provider/provider.dart';

class PaintScreen extends StatelessWidget {
  final String? imagePath;
  const PaintScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaintModel(),
      child: Scaffold(
        body: Stack(
          children: [
            if (imagePath != null && imagePath!.isNotEmpty)
              Positioned.fill(
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
            const Align(alignment: Alignment.center, child: PaintCanvas()),
            const PaintUi(),
          ],
        ),
      ),
    );
  }
}
