import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';
import 'package:provider/provider.dart';

// TODO: Add a method to return the current state of the canvas as an image.
// TODO: Move the external image here.
class PaintCanvas extends StatelessWidget {
  const PaintCanvas({super.key});

  static const Size canvasSize = Size(800, 800);
  static final Rect canvasBounds = Rect.fromLTWH(
    0,
    0,
    canvasSize.width,
    canvasSize.height,
  );

  @override
  Widget build(BuildContext context) {
    final paintModel = context.read<PaintModel>();
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: SizedBox.fromSize(
        size: canvasSize,
        child: Stack(
          children: [
            RepaintBoundary(
              child: SizedBox(
                width: canvasSize.width,
                height: canvasSize.height,
                child: CustomPaint(painter: GraffitiPainter(paintModel)),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) =>
                  paintModel.beginStroke(details.localPosition),
              onPanUpdate: (details) {
                final point = details.localPosition;
                if (canvasBounds.contains(point)) {
                  paintModel.extendStroke(point);
                } else {
                  paintModel.finishStroke();
                }
              },
              onPanEnd: (_) => paintModel.finishStroke(),
              onPanCancel: paintModel.cancelStroke,
              child: RepaintBoundary(
                child: SizedBox(
                  width: canvasSize.width,
                  height: canvasSize.height,
                  child: CustomPaint(painter: CurrentLinePainter(paintModel)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
