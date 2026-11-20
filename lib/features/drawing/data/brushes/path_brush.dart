import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/brush.dart';
import 'package:frontend/features/drawing/data/brushes/polyline.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

abstract class PathBrush extends Brush {
  const PathBrush();

  Paint createPaint(DrawnLine line) => Paint()
    ..color = line.color
    ..strokeWidth = line.width
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, DrawnLine line) =>
      canvas.drawPath(line.points.toPath(), createPaint(line));
}
