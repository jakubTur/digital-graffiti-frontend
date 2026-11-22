import 'package:flutter/material.dart';

extension Polyline on List<Offset> {
  Path toPath() {
    final path = Path()..moveTo(first.dx, first.dy);
    for (final point in skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  List<Offset> resample(double spacing) {
    final samples = [first];
    var travelled = 0.0;
    for (var i = 1; i < length; i++) {
      var from = this[i - 1];
      final to = this[i];
      var remaining = (to - from).distance;
      while (travelled + remaining >= spacing) {
        from += (to - from) * ((spacing - travelled) / remaining);
        samples.add(from);
        remaining = (to - from).distance;
        travelled = 0;
      }
      travelled += remaining;
    }
    return samples;
  }
}
