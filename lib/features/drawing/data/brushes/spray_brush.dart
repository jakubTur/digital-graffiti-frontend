import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/data/brushes/brush.dart';
import 'package:frontend/features/drawing/data/brushes/polyline.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class SprayBrush extends Brush {
  const SprayBrush();

  static const _dotSize = 1.5;

  @override
  String get name => 'Spray paint';

  @override
  IconData get icon => PhosphorIconsRegular.sprayBottle;

  @override
  void paint(Canvas canvas, DrawnLine line) {
    final random = Random(line.points.first.hashCode);
    final radius = line.width / 2;
    final dots = [
      for (final center in line.points.resample(max(1.0, radius / 2)))
        for (var i = 0; i < line.width.ceil(); i++)
          center +
              Offset.fromDirection(
                random.nextDouble() * 2 * pi,
                radius * random.nextDouble(),
              ),
    ];
    canvas.drawPoints(
      PointMode.points,
      dots,
      Paint()
        ..color = line.color
        ..strokeWidth = _dotSize
        ..strokeCap = StrokeCap.round,
    );
  }
}
