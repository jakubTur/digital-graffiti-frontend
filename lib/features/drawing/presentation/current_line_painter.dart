import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';

// widget that paints the currently-painted stroke.
// used as a separate painter so that painting a new stroke does not repaint all existing strokes.
// TODO: if painters become more complex, consider uniting this with the basic painter or finding another way to share logic. right now that's not needed since painters are small.
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