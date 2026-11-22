import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/path_brush.dart';

class RoundBrush extends PathBrush {
  const RoundBrush();

  @override
  String get name => 'Brush';

  @override
  IconData get icon => PhosphorIconsRegular.paintBrush;
}
