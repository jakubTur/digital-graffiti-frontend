import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/custom_color_dialog.dart';

/// color palette.
/// contains some starter colors and a custom color picker.
class ColorPalette extends StatelessWidget {
  static const presetColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  bool _isSelected(Color color) =>
      color.toARGB32() == selectedColor.toARGB32();

  bool get _isCustomColor => !presetColors.any(_isSelected);

  Future<void> _pickCustomColor(BuildContext context) async {
    final color = await CustomColorDialog.show(context, selectedColor);
    if (color != null) onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final color in presetColors)
          _Swatch(
            color: color,
            isSelected: _isSelected(color),
            onTap: () => onColorSelected(color),
          ),
        _Swatch(
          color: _isCustomColor ? selectedColor : Colors.grey.shade300,
          isSelected: _isCustomColor,
          onTap: () => _pickCustomColor(context),
          child: const Icon(Icons.add, color: Colors.black54),
        ),
      ],
    ),
  );
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.black26,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: child,
      ),
    ),
  );
}
