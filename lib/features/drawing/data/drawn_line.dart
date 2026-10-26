import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

// Data structure for paint strokes on the canvas.
// Data structure for paint strokes already drawn on the canvas.
class DrawnLine {

  Path path = Path();
  double strokeWidth = 10;
  Color color = Colors.black;
  bool isLineFinished = false;

  DrawnLine(this.path, this.color, this.strokeWidth);

  Paint getPaint() {
    var paint = Paint();
    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    return paint;
  }
}
