import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class PaintModel extends ChangeNotifier {
  final List<DrawnLine> _lines = [];
  DrawnLine? _currentLine;
  Color _brushColor = Colors.black;
  double _brushWidth = 10;

  List<DrawnLine> get lines => List<DrawnLine>.unmodifiable(_lines);
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
    notifyListeners();
  }

  void extendStroke(Offset point) {
    final line = _currentLine;
    if (line == null) return;
    line.path.lineTo(point.dx, point.dy);
    notifyListeners();
  }

  void finishStroke() {
    final line = _currentLine;
    if (line == null) return;
    _lines.add(line);
    _currentLine = null;
    notifyListeners();
  }

  void cancelStroke() {
    if (_currentLine == null) return;
    _currentLine = null;
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _lines.removeLast();
    notifyListeners();
  }

  void clear() {
    if (!hasStrokes) return;
    _lines.clear();
    _currentLine = null;
    notifyListeners();
  }
}
