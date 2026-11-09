import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brush_settings.dart';
import 'package:frontend/features/drawing/data/canvas_exporter.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

// main class for managing canvas state and making it accessible to child widgets.
// stores basically all state related to the painting itself, strokes,
// and exposes methods for safely managing said state.
// in order to use this in a widget, use a Consumer.
class PaintModel extends ChangeNotifier {
  PaintModel({
    required this.brush,
    required this.exporter,
    this.backgroundImagePath,
  });

  // settings of currently used brush.
  final BrushSettings brush;
  final CanvasExporter exporter;

  // background image is stored here for export funcitonality to work correctly
  final String? backgroundImagePath;
  bool _isExporting = false;
  bool get isExporting => _isExporting;

  Size _canvasSize = const Size(800, 800); // overridden by background image size; otherwise this value is used as default
  Size get canvasSize => _canvasSize;

  void setCanvasSize(Size size) {
    if (_canvasSize == size) return;
    _canvasSize = size;
    notifyListeners();
  }

  // already-drawn lines (with getter)
  final List<DrawnLine> _lines = [];
  List<DrawnLine> get lines => UnmodifiableListView(_lines);

  // currently-drawn line is stored separately so as not to trigger unnecessary updates.
  // for that same reason, it has its own painter (see CurrentLinePainter).
  // nullable because it's null when no line is being drawn.
  DrawnLine? _currentLine;
  DrawnLine? get currentLine => _currentLine;

  // change notifiers. used to update the canvas.
  final ChangeNotifier _linesRepaint = ChangeNotifier();
  final ChangeNotifier _currentLineRepaint = ChangeNotifier();
  Listenable get linesRepaint => _linesRepaint;
  Listenable get currentLineRepaint => _currentLineRepaint;

  bool get canUndo => _lines.isNotEmpty;
  bool get hasStrokes => _lines.isNotEmpty || _currentLine != null;

  // call based on gestures
  void beginStroke(Offset point) {
    final path = Path()..moveTo(point.dx, point.dy);
    _currentLine = DrawnLine(path, brush.color, brush.width);
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  // call based on gestures
  void extendStroke(Offset point) {
    final line = _currentLine;
    if (line == null) return;
    line.path.lineTo(point.dx, point.dy);
    _currentLineRepaint.notifyListeners();
  }

  // call based on gestures
  void finishStroke() {
    final line = _currentLine;
    if (line == null) return;
    _lines.add(line);
    _currentLine = null;
    _linesRepaint.notifyListeners();
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  // call based on gestures
  void cancelStroke() {
    if (_currentLine == null) return;
    _currentLine = null;
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  // removes the last-drawn finished line (NOT the current stroke).
  void undo() {
    if (!canUndo) return;
    _lines.removeLast();
    _linesRepaint.notifyListeners();
    notifyListeners();
  }

  // clears canvas.
  void clear() {
    if (!hasStrokes) return;
    _lines.clear();
    _currentLine = null;
    _linesRepaint.notifyListeners();
    _currentLineRepaint.notifyListeners();
    notifyListeners();
  }

  // exports the image as a future containing raw bytes using PictureRecorder.
  // TODO: decide if this is really the correct export format.
  Future<Uint8List> exportImage() async {
    if (_isExporting) throw StateError('Image export is already in progress.');
    _isExporting = true;
    notifyListeners();
    try {
      finishStroke();
      return await exporter.export(
        lines: lines,
        size: _canvasSize,
        backgroundImagePath: backgroundImagePath,
      );
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _linesRepaint.dispose();
    _currentLineRepaint.dispose();
    super.dispose();
  }

}
