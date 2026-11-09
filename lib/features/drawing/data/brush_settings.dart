import 'package:flutter/material.dart';

/// class storing brush settings. (moved from stroke data)
/// for now: width, color. later on: some other stuff probably.
class BrushSettings extends ChangeNotifier {
  static const double minWidth = 1;
  static const double maxWidth = 50;

  Color _color = Colors.black;
  double _width = 10;
  Color get color => _color;
  double get width => _width;

  void setColor(Color color) {
    if (_color == color) return;
    _color = color;
    notifyListeners();
  }

  void setWidth(double width) {
    if (!width.isFinite || width < minWidth || width > maxWidth) {
      throw ArgumentError.value(
        width,
        'width',
        'Must be between $minWidth and $maxWidth.',
      );
    }
    if (_width == width) return;
    _width = width;
    notifyListeners();
  }
}
