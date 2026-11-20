import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/path_brush.dart';

class RoundBrush extends PathBrush {
  const RoundBrush();

  @override
  String get name => 'Brush';

  @override
  IconData get icon => Icons.brush;
}
