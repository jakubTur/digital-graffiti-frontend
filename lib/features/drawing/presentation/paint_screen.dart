import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';
import 'package:frontend/features/drawing/presentation/graffiti_painter.dart';

class PaintScreen extends StatefulWidget {
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
          children: [
            CustomPaint(painter: GraffitiPainter(lines)),
            buildAllPaths(context),
            buildCurrentPath(context),
          ],
        ),
      ),
    );
  }

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

  GestureDetector buildCurrentPath(BuildContext context) {
    void onPanStart(DragStartDetails details) {
      print('User started drawing');
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      print(point);
      setState(() {
        var path = Path();
        path.moveTo(point.dx, point.dy);
        currentLine = DrawnLine(path, graffitiColor, graffitiWidth);
        lines.add(currentLine);
      });
    }

    void onPanUpdate(DragUpdateDetails details) {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      print(point);
      setState(() {
        currentLine.path.lineTo(point.dx, point.dy);
      });
    }

    void onPanEnd(DragEndDetails details) {
      print('User ended drawing');
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
