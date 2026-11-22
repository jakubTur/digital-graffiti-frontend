import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/domain/entities/drawn_line.dart';


/// brush class.
abstract class Brush {
  const Brush();

  String get name;
  IconData get icon;

  void paint(Canvas canvas, DrawnLine line);
}
