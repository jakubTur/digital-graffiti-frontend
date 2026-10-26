import 'package:flutter/material.dart';

class DrawnLine {
  final Path path;
  final Color color;
  final double strokeWidth;
  late final Paint _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  DrawnLine(this.path, this.color, this.strokeWidth);

  Paint getPaint() => _paint;
}
