import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// widget for setting a custom color (outside of the example palette).
class CustomColorDialog extends StatefulWidget {
  final Color initialColor;

  const CustomColorDialog({super.key, required this.initialColor});

  static Future<Color?> show(BuildContext context, Color initialColor) =>
      showDialog<Color>(
        context: context,
        builder: (_) => CustomColorDialog(initialColor: initialColor),
      );

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
  late Color _color = widget.initialColor;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Pick a color'),
    content: SingleChildScrollView(
      child: ColorPicker(
        pickerColor: _color,
        onColorChanged: (color) => setState(() => _color = color),
        enableAlpha: false,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(_color),
        child: const Text('Select'),
      ),
    ],
  );
}
