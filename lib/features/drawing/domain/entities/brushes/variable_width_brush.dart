import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/brush.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/polyline.dart';
import 'package:frontend/features/drawing/domain/entities/drawn_line.dart';

/// parent class for brushes whose width... varies... throughout the stroke. shocking i know.
abstract class VariableWidthBrush extends Brush {
  const VariableWidthBrush();

  static const spacing = 2.0;

  double segmentWidth(DrawnLine line, List<Offset> points, int index);

  @override
  void paint(Canvas canvas, DrawnLine line) {
    final points = line.points.resample(spacing);
    final paint = Paint()
      ..color = line.color
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      paint.strokeWidth = segmentWidth(line, points, i);
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }
}
