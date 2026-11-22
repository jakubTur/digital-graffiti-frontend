import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/path_brush.dart';
import 'package:frontend/features/drawing/domain/entities/drawn_line.dart';

class AirBrush extends PathBrush {
  const AirBrush();

  @override
  String get name => 'Airbrush';

  @override
  IconData get icon => PhosphorIconsRegular.gradient;

  @override
  Paint createPaint(DrawnLine line) => super.createPaint(line)
    ..strokeWidth = line.width / 2
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, line.width / 4);
}
