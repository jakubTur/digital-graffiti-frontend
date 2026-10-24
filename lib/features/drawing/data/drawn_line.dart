import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

// Data structure for paint strokes on the canvas.
class DrawnLine {
  Path path = Path();
  Paint paint = Paint();
  DrawnLine(this.path, Color color, double width) {
    paint.color = color;
    paint.strokeWidth = width;
    paint.style = PaintingStyle.stroke;
  }
}
