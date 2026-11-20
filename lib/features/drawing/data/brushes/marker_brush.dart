import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/data/brushes/path_brush.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class MarkerBrush extends PathBrush {
  const MarkerBrush();

  static const _opacity = 0.4;

  @override
  String get name => 'Marker';

  @override
  IconData get icon => PhosphorIconsRegular.highlighter;

  @override
  Paint createPaint(DrawnLine line) => super.createPaint(line)
    ..color = line.color.withValues(alpha: _opacity)
    ..strokeCap = StrokeCap.square;
}
