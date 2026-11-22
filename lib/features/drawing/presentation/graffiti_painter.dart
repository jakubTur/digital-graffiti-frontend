import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/state/paint_model.dart';

class GraffitiPainter extends CustomPainter {
  final PaintModel paintModel;

  GraffitiPainter(this.paintModel) : super(repaint: paintModel.canvasRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    final finishedStrokes = paintModel.finishedStrokes;
    if (finishedStrokes != null) {
      canvas.drawImage(
        finishedStrokes,
        Offset.zero,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    paintModel.currentLine?.paint(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(GraffitiPainter oldDelegate) {
    return !identical(oldDelegate.paintModel, paintModel);
  }
}
