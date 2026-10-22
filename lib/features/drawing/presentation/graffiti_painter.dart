import 'package:flutter/material.dart';
import 'package:custom_paint/custom_paint.dart';

class GraffitiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // todo: painting
    //// 1
    Offset startPoint = Offset(0, 0);
    // 2
    Offset endPoint = Offset(size.width, size.height);
    // 3
    Paint paint = Paint();
    // 4
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // todo: should repaint
    return true;
  }
}
