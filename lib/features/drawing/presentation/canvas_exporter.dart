import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// export code from PaintModel isolated into its own class to keep the model clean.
class CanvasExporter {
  Future<Uint8List> export({
    required Size size,
    ui.Image? strokes,
    ui.Image? background,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final layer in [background, strokes].nonNulls) {
      canvas.drawImage(layer, Offset.zero, Paint());
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
