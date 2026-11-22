import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/brush.dart';

/// contains data of a single stroke.
class DrawnLine {

  /// brush.
  final Brush brush;
  final Color color;
  final double width;

  /// if true, this line is being used to erase other lines.
  final bool erases;

  /// points in the line.
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
