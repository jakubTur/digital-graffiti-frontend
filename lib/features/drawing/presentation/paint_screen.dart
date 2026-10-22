import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';

class PaintScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow[100],
      child: CustomPaint(
        painter: GraffitiPainter(),
      ),
    );
  }
}
