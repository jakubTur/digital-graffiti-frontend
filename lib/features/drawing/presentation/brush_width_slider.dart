import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brush_settings.dart';

/// slider for brush widgth.
class BrushWidthSlider extends StatelessWidget {
  final double width;

  /// callback to call when setting width.
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const BrushWidthSlider({
    super.key,
    required this.width,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) => Slider(
    value: width,
    min: BrushSettings.minWidth,
    max: BrushSettings.maxWidth,
    label: width.round().toString(),
    divisions: (BrushSettings.maxWidth - BrushSettings.minWidth).round(),
    onChanged: onChanged,
    onChangeEnd: onChangeEnd,
  );
}
