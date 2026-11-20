import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';

// paint canvas.
// displays strokes.
class PaintCanvas extends StatelessWidget {
  final PaintModel paintModel;
  final Size size;

  const PaintCanvas({super.key, required this.paintModel, required this.size});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: RepaintBoundary(
        child: CustomPaint(size: size, painter: GraffitiPainter(paintModel)),
      ),
    );
  }
}
