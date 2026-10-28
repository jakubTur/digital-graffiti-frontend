import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';
import 'package:frontend/features/drawing/presentation/current_line_painter.dart';

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
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          children: [
            RepaintBoundary(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: CustomPaint(painter: GraffitiPainter(paintModel)), // for finished strokes
              ),
            ),
            RepaintBoundary(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: CustomPaint(painter: CurrentLinePainter(paintModel)), // for current stroke
              ),
            ),
          ],
        ),
      ),
    );
  }
}
