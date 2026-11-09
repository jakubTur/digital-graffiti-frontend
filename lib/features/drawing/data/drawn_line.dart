import 'package:flutter/material.dart';

/// contains data of a single stroke.
/// does not store the brush itself because umm uhh mind your own damn business.
/// (could potentially be refactored to store the actual brush but there's no need for that now. can be done later if needed.)
class DrawnLine {
  final Path path;
  final Color color;
  final double strokeWidth;
  late final Paint _paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  DrawnLine(this.path, this.color, this.strokeWidth);

  Paint getPaint() => _paint;
}
