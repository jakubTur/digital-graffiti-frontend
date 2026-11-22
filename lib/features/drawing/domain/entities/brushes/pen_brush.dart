import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/variable_width_brush.dart';
import 'package:frontend/features/drawing/domain/entities/drawn_line.dart';

class PenBrush extends VariableWidthBrush {
  const PenBrush();

  static const _minScale = 0.15;
  static const _taperLengthFactor = 3.0;

  @override
  String get name => 'Pen';

  @override
  IconData get icon => PhosphorIconsRegular.pen;

  @override
  double segmentWidth(DrawnLine line, List<Offset> points, int index) {
    final distanceToEnd =
        min(index, points.length - 2 - index) * VariableWidthBrush.spacing;
    final taper = (distanceToEnd / (line.width * _taperLengthFactor)).clamp(
      0.0,
      1.0,
    );
    return line.width * (_minScale + (1 - _minScale) * sqrt(taper));
  }
}
