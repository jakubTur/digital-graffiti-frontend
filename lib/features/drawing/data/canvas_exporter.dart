import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/drawn_line.dart';

// export code from PaintModel isolated into its own class to keep the model clean.
class CanvasExporter {
  Future<Uint8List> export({
    required List<DrawnLine> lines,
    required Size size,
    ui.Image? background,
    bool includeBackground = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (includeBackground && background != null) {
      canvas.drawImage(background, Offset.zero, Paint());
    }
    for (final line in lines) {
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
  }
}
