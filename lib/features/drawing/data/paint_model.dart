import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

// main class for managing canvas state and making it accessible to child widgets.
// stores basically all state related to the painting itself, the current brush, strokes,
// and exposes methods for safely managing said state.
// in order to use this in a widget, use a Consumer.
class PaintModel extends ChangeNotifier {
  PaintModel({this.backgroundImagePath});

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

  // brush state:
  Color _brushColor = Colors.black;
  double _brushWidth = 10;
  Color get brushColor => _brushColor;
  double get brushWidth => _brushWidth;

  bool get canUndo => _lines.isNotEmpty;
  bool get hasStrokes => _lines.isNotEmpty || _currentLine != null;

  // currently unused, but will be used when multiple brushes are added.
  void setBrushColor(Color color) {
    if (_brushColor == color) return;
    _brushColor = color;
    notifyListeners();
  }

  // currently unused, but will be used when multiple brushes are added.
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

  // call based on gestures
  void beginStroke(Offset point) {
    final path = Path()..moveTo(point.dx, point.dy);
    _currentLine = DrawnLine(path, _brushColor, _brushWidth);
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
  // TODO: verify if this is really the correct export format.
  Future<Uint8List> exportImage() async {
    if (_isExporting) throw StateError('Image export is already in progress.');
    _isExporting = true;
    notifyListeners();
    try {
      finishStroke();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final size = _canvasSize;

      if (backgroundImagePath != null && backgroundImagePath!.isNotEmpty) {
        final codec = await ui.instantiateImageCodec(
          await File(backgroundImagePath!).readAsBytes(),
        );
        final frame = await codec.getNextFrame();
        canvas.drawImageRect(
          frame.image,
          Rect.fromLTWH(
            0,
            0,
            frame.image.width.toDouble(),
            frame.image.height.toDouble(),
          ),
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint(),
        );
        frame.image.dispose();
        codec.dispose();
      }

      for (final line in _lines) {
        canvas.drawPath(line.path, line.getPaint());
      }

      final image = await recorder.endRecording().toImage(
        size.width.ceil(),
        size.height.ceil(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('Could not encode the canvas image.');
      return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
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
