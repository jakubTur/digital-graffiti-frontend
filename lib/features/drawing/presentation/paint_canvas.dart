import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';

// Paint canvas.
// TODO: Add a method to return the current state of the canvas as an image.
// TODO: Move the external image here.
class PaintCanvas extends StatefulWidget {
  const PaintCanvas({super.key});

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas> {
  final linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  final currentLineStreamController = StreamController<DrawnLine>.broadcast();

  Color graffitiColor = Colors.black;
  double graffitiWidth = 10;
  DrawnLine currentLine = DrawnLine(Path(), Colors.black, 10); // The line currently being drawn
  List<DrawnLine> lines = []; // All already-drawn lines

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: StreamBuilder<List<DrawnLine>>(
              stream: linesStreamController.stream,
              builder: (context, snapshot) {
                return CustomPaint(painter: GraffitiPainter(lines));
              },
            ),
          ),
        ),
        GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: RepaintBoundary(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: StreamBuilder<DrawnLine>(
                stream: currentLineStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(painter: GraffitiPainter([currentLine]));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    final path = Path()..moveTo(point.dx, point.dy);
    currentLine = DrawnLine(path, graffitiColor, graffitiWidth);
    currentLineStreamController.add(currentLine);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    currentLine.path.lineTo(point.dx, point.dy);
    currentLineStreamController.add(currentLine);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(currentLine);
    linesStreamController.add(lines);
  }
}
