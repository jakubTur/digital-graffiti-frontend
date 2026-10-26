import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class PaintModel extends ChangeNotifier {
  final List<DrawnLine> _lines = [];
  late final List<DrawnLine> _linesView = UnmodifiableListView(_lines);
  final ChangeNotifier _linesRepaint = ChangeNotifier();
  final ChangeNotifier _currentLineRepaint = ChangeNotifier();
  DrawnLine? _currentLine;
  Color _brushColor = Colors.black;
  double _brushWidth = 10;

  List<DrawnLine> get lines => _linesView;
  Listenable get linesRepaint => _linesRepaint;
  Listenable get currentLineRepaint => _currentLineRepaint;
  DrawnLine? get currentLine => _currentLine;
  Color get brushColor => _brushColor;
  double get brushWidth => _brushWidth;
  bool get canUndo => _lines.isNotEmpty;
  bool get hasStrokes => _lines.isNotEmpty || _currentLine != null;

  void setBrushColor(Color color) {
    if (_brushColor == color) return;
    _brushColor = color;
    notifyListeners();
  }

  void setBrushWidth(double width) {
    if (!width.isFinite || width <= 0) {
      throw ArgumentError.value(
        width,
        'width',
        'Must be a finite value greater than zero.',
      );
    }
    if (_brushWidth == width) return;
    _brushWidth = width;
    notifyListeners();
  }

  void beginStroke(Offset point) {
    final path = Path()..moveTo(point.dx, point.dy);
    _currentLine = DrawnLine(path, _brushColor, _brushWidth);
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  void extendStroke(Offset point) {
    final line = _currentLine;
    if (line == null) return;
    line.path.lineTo(point.dx, point.dy);
    _currentLineRepaint.notifyListeners();
  }

  void finishStroke() {
    final line = _currentLine;
    if (line == null) return;
    _lines.add(line);
    _currentLine = null;
    _linesRepaint.notifyListeners();
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  void cancelStroke() {
    if (_currentLine == null) return;
    _currentLine = null;
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _lines.removeLast();
    _linesRepaint.notifyListeners();
    notifyListeners();
  }

  void clear() {
    if (!hasStrokes) return;
    _lines.clear();
    _currentLine = null;
    _linesRepaint.notifyListeners();
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  @override
  void dispose() {
    _linesRepaint.dispose();
    _currentLineRepaint.dispose();
    super.dispose();
  }
}
