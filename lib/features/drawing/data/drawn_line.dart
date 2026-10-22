// Simple data class for drawing
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class DrawnLine {
  Path path = Path();
  Paint paint = Paint();
  DrawnLine(Path this.path, Color color, double width) {
    paint.color = color;
    paint.strokeWidth = width;
  }
}
