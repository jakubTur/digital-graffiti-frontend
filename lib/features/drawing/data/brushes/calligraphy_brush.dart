import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/variable_width_brush.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class CalligraphyBrush extends VariableWidthBrush {
  const CalligraphyBrush();

  static const _minScale = 0.2;
  static const _nibAngle = pi / 4;

  @override
  String get name => 'Calligraphy';

  @override
  IconData get icon => Icons.history_edu;

  @override
  double segmentWidth(DrawnLine line, List<Offset> points, int index) {
    final direction = (points[index + 1] - points[index]).direction;
    final nibAlignment = sin(direction - _nibAngle).abs();
    return line.width * (_minScale + (1 - _minScale) * nibAlignment);
  }
}
