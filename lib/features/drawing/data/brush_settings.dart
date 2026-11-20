import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/brush.dart';
import 'package:frontend/features/drawing/data/brushes/round_brush.dart';

/// class storing brush settings. (moved from stroke data)
class BrushSettings extends ChangeNotifier {
  static const double minWidth = 1;
  static const double maxWidth = 50;

  /// current brush.
  Brush _brush = const RoundBrush();

  /// if true, brush is being used to erase instead of add color.
  bool _isErasing = false;

  /// color of stroke (irrelevent if _isErasing is true)
  Color _color = Colors.black;

  /// width of brush
  double _width = 10;

  ///getters:
  Brush get brush => _brush;
  bool get isErasing => _isErasing;
  Color get color => _color;
  double get width => _width;

  void setBrush(Brush brush) {
    if (_brush == brush) return;
    _brush = brush;
    notifyListeners();
  }

  void setErasing(bool isErasing) {
    if (_isErasing == isErasing) return;
    _isErasing = isErasing;
    notifyListeners();
  }

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
