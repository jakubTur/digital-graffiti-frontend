import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class GraffitiPainter extends CustomPainter {
  final List<DrawnLine> lines;

  GraffitiPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (int lineNo = 0; lineNo < lines.length; lineNo++) {
      canvas.drawPath(lines[lineNo].path, lines[lineNo].paint);
    }
  }

  @override
  bool shouldRepaint(GraffitiPainter oldDelegate) {
    return (oldDelegate.lines != lines);
  }
}
