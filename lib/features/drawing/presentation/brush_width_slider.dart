import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brush_settings.dart';

/// slider for brush widgth.
class BrushWidthSlider extends StatelessWidget {
  final double width;

  /// callback to call when setting width.
  final ValueChanged<double> onChanged;

  const BrushWidthSlider({
    super.key,
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: 3,
    child: SizedBox(
      width: 250,
      height: 48,
      child: Slider(
        value: width,
        min: BrushSettings.minWidth,
        max: BrushSettings.maxWidth,
        label: width.round().toString(),
        divisions: (BrushSettings.maxWidth - BrushSettings.minWidth).round(),
        onChanged: onChanged,
      ),
    ),
  );
}
