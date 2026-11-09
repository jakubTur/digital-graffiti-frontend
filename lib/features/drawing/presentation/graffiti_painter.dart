import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';

// painter for all already-drawn strokes.
// updates when a stroke is added/removed.
class GraffitiPainter extends CustomPainter {
  final PaintModel paintModel;

  GraffitiPainter(this.paintModel) : super(repaint: paintModel.linesRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in paintModel.lines) {
      canvas.drawPath(line.path, line.getPaint());
    }
  }

  @override
  bool shouldRepaint(GraffitiPainter oldDelegate) {
    return !identical(oldDelegate.paintModel, paintModel);
  }
}