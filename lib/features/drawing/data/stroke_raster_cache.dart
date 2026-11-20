import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

class StrokeRasterCache {
  ui.Image? _image;
  ui.Image? get image => _image;

  void add(DrawnLine line, Size size) => _render([line], size, base: _image);

  void rebuild(Iterable<DrawnLine> lines, Size size) => _render(lines, size);

  void _render(Iterable<DrawnLine> lines, Size size, {ui.Image? base}) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (base != null) canvas.drawImage(base, Offset.zero, Paint());
    for (final line in lines) {
      line.paint(canvas);
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(size.width.ceil(), size.height.ceil());
    picture.dispose();
    _image?.dispose();
    _image = image;
  }

  void dispose() => _image?.dispose();
}
