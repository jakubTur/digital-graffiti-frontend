import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';
import 'package:provider/provider.dart';

// Paint canvas.
// TODO: Add a method to return the current state of the canvas as an image.
// TODO: Move the external image here.
class PaintCanvas extends StatefulWidget {
  const PaintCanvas({super.key});

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas> {
  static const Size canvasSize = Size(800, 800);

  @override
  Widget build(BuildContext context) {
    final paintModel = context.watch<PaintModel>();
    return Stack(
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: CustomPaint(painter: GraffitiPainter(paintModel.lines)),
          ),
        ),
        GestureDetector(
          onPanStart: (details) =>
              paintModel.beginStroke(details.localPosition),
          onPanUpdate: (details) =>
              paintModel.extendStroke(details.localPosition),
          onPanEnd: (_) => paintModel.finishStroke(),
          onPanCancel: paintModel.cancelStroke,
          child: RepaintBoundary(
            child: SizedBox(
              width: canvasSize.width,
              height: canvasSize.height,
              child: CustomPaint(
                painter: GraffitiPainter([
                  if (paintModel.currentLine case final currentLine?)
                    currentLine,
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
