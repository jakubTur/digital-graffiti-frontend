import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';

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

class CurrentLinePainter extends CustomPainter {
  final PaintModel paintModel;

  CurrentLinePainter(this.paintModel)
    : super(repaint: paintModel.currentLineRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    final line = paintModel.currentLine;
    if (line != null) {
      canvas.drawPath(line.path, line.getPaint());
    }
  }

  @override
  bool shouldRepaint(CurrentLinePainter oldDelegate) {
    return !identical(oldDelegate.paintModel, paintModel);
  }
}
