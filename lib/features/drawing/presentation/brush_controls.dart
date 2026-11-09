import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/brush_width_slider.dart';
import 'package:frontend/features/drawing/presentation/color_palette.dart';

/// widget for brush controls.
/// lets you customize width and color.
/// TODO (not urgent): figure out what other things can be customized, and implement those, potentially isolating them to a new menu.
class BrushControls extends StatelessWidget {
  final Color color;
  final double width;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;

  const BrushControls({
    super.key,
    required this.color,
    required this.width,
    required this.onColorChanged,
    required this.onWidthChanged,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Align(
              alignment: Alignment.topCenter,
              child: ColorPalette(
                selectedColor: color,
                onColorSelected: onColorChanged,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: BrushWidthSlider(width: width, onChanged: onWidthChanged),
          ),
        ],
      ),
    ),
  );
}
