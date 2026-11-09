import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';

// simple widget for displaying the background image.
// this is just here to keep PaintScreen clean and concise really.
// image is stored in paintModel because it's required for  the export functionality.
class CanvasBackgroundImage extends StatelessWidget {
  final PaintModel paintModel;

  const CanvasBackgroundImage({
    super.key,
    required this.paintModel,
  });

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: paintModel.canvasSize,
    child:
        paintModel.backgroundImagePath == null ||
            paintModel.backgroundImagePath!.isEmpty
        ? null
        : Image.file(
            File(paintModel.backgroundImagePath!),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              final image = (child as RawImage).image;
              if (image != null) {
                final size = Size(
                  image.width.toDouble(),
                  image.height.toDouble(),
                );
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => paintModel.setCanvasSize(size),
                );
              }
              return child;
            },
          ),
  );
}
