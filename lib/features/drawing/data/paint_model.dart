import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brush_settings.dart';
import 'package:frontend/features/drawing/data/canvas_exporter.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';
import 'package:frontend/features/drawing/data/stroke_raster_cache.dart';

// main class for managing canvas state and making it accessible to child widgets.
// stores basically all state related to the painting itself, strokes,
// and exposes methods for safely managing said state.
// in order to use this in a widget, use a Consumer.
class PaintModel extends ChangeNotifier {
  PaintModel({
    required this.brushSettings,
    required this.exporter,
    this.backgroundLayers = const [],
  });

  // settings of currently used brush.
  final BrushSettings brushSettings;
  final CanvasExporter exporter;


  // list of uneditable layers as background (leaving a comment renders child drawings here too)
  final List<ImageProvider> backgroundLayers;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  Size _canvasSize = const Size(800, 800); // overridden by background image size; otherwise this value is used as default
  Size get canvasSize => _canvasSize;

  ui.Image? _backgroundImage;

  void setBackgroundImage(ui.Image image) {
    _backgroundImage = image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    if (_canvasSize == size) return;
    _canvasSize = size;
    _cache.rebuild(_lines, size);
    notifyListeners();
  }

  // already-drawn lines
  final List<DrawnLine> _lines = [];
  final StrokeRasterCache _cache = StrokeRasterCache();
  ui.Image? get finishedStrokes => _cache.image;

  // currently-drawn line is stored separately so as not to trigger unnecessary updates.
  // nullable because it's null when no line is being drawn.
  DrawnLine? _currentLine;
  DrawnLine? get currentLine => _currentLine;

  // change notifier. used to update the canvas.
  final ChangeNotifier _canvasRepaint = ChangeNotifier();
  Listenable get canvasRepaint => _canvasRepaint;

  bool get canUndo => _lines.isNotEmpty;
  bool get hasStrokes => _lines.isNotEmpty || _currentLine != null;

  // call based on gestures
  void beginStroke(Offset point) {
    _currentLine = DrawnLine(
      brush: brushSettings.brush,
      color: brushSettings.color,
      width: brushSettings.width,
      erases: brushSettings.isErasing,
      start: point,
    );
    _canvasRepaint.notifyListeners();
    notifyListeners();
  }

  // call based on gestures
  void extendStroke(Offset point) {
    final line = _currentLine;
    if (line == null) return;
    line.addPoint(point);
    _canvasRepaint.notifyListeners();
  }

  // call based on gestures
  void finishStroke() {
    final line = _currentLine;
    if (line == null) return;
    _lines.add(line);
    _cache.add(line, _canvasSize);
    _currentLine = null;
    _canvasRepaint.notifyListeners();
    notifyListeners();
  }

  // call based on gestures
  void cancelStroke() {
    if (_currentLine == null) return;
    _currentLine = null;
    _canvasRepaint.notifyListeners();
    notifyListeners();
  }

  // removes the last-drawn finished line (NOT the current stroke).
  void undo() {
    if (!canUndo) return;
    _lines.removeLast();
    _cache.rebuild(_lines, _canvasSize);
    _canvasRepaint.notifyListeners();
    notifyListeners();
  }

  // clears canvas.
  void clear() {
    if (!hasStrokes) return;
    _lines.clear();
    _currentLine = null;
    _cache.rebuild(_lines, _canvasSize);
    _canvasRepaint.notifyListeners();
    notifyListeners();
  }

  // exports the image as a future containing raw bytes using PictureRecorder.
  // TODO: decide if this is really the correct export format.
  Future<Uint8List> exportImage({bool includeBackground = false}) async {
    if (_isExporting) throw StateError('Image export is already in progress.');
    _isExporting = true;
    notifyListeners();
    try {
      finishStroke();
      return await exporter.export(
        size: _canvasSize,
        strokes: _cache.image,
        background: includeBackground ? _backgroundImage : null,
      );
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cache.dispose();
    _canvasRepaint.dispose();
    super.dispose();
  }

}
