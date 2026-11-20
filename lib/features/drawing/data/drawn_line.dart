import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/brush.dart';

/// contains data of a single stroke.
class DrawnLine {
  final Brush brush;
  final Color color;
  final double width;
  final bool erases;
  final List<Offset> _points;

  DrawnLine({
    required this.brush,
    required this.color,
    required this.width,
    required this.erases,
    required Offset start,
  }) : _points = [start];

  List<Offset> get points => UnmodifiableListView(_points);

  void addPoint(Offset point) => _points.add(point);

  void paint(Canvas canvas) {
    if (erases) canvas.saveLayer(null, Paint()..blendMode = BlendMode.dstOut);
    brush.paint(canvas, this);
    if (erases) canvas.restore();
  }
}
