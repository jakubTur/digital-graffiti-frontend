import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  final currentLineStreamController = StreamController<DrawnLine>.broadcast();

  Color graffitiColor = Colors.black;
  double graffitiWidth = 10;
  DrawnLine currentLine = DrawnLine(Path(), Colors.black, 10);
  List<DrawnLine> lines = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        color: Colors.green[100],
        child: Stack(
          children: [buildAllPaths(context), buildCurrentPath(context)],
        ),
      ),
    );
  }

  // Builds all lines that have already been drawn.
  // Does not build the currently-drawn line.
  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(painter: GraffitiPainter(lines));
          },
        ),
      ),
    );
  }

  // Builds the line that is currently being drawn.
  // Separate from buildAllPaths for performance (you don't want to rebuild lines that were already painted).
  GestureDetector buildCurrentPath(BuildContext context) {
    void onPanStart(DragStartDetails details) {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      var path = Path();
      path.moveTo(point.dx, point.dy);
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

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(painter: GraffitiPainter([currentLine]));
            },
          ),
        ),
      ),
    );
  }
}
