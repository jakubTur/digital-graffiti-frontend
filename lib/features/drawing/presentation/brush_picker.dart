import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/brushes/air_brush.dart';
import 'package:frontend/features/drawing/data/brushes/brush.dart';
import 'package:frontend/features/drawing/data/brushes/calligraphy_brush.dart';
import 'package:frontend/features/drawing/data/brushes/marker_brush.dart';
import 'package:frontend/features/drawing/data/brushes/pen_brush.dart';
import 'package:frontend/features/drawing/data/brushes/round_brush.dart';
import 'package:frontend/features/drawing/data/brushes/spray_brush.dart';

/// widget for picking a brush.
class BrushPicker extends StatelessWidget {
  static const brushes = <Brush>[
    RoundBrush(),
    PenBrush(),
    CalligraphyBrush(),
    MarkerBrush(),
    AirBrush(),
    SprayBrush(),
  ];

  final Brush selectedBrush;
  final ValueChanged<Brush> onBrushSelected;

  const BrushPicker({
    super.key,
    required this.selectedBrush,
    required this.onBrushSelected,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final brush in brushes)
          IconButton(
            tooltip: brush.name,
            icon: Icon(brush.icon),
            isSelected: brush == selectedBrush,
            onPressed: () => onBrushSelected(brush),
          ),
      ],
    ),
  );
}
