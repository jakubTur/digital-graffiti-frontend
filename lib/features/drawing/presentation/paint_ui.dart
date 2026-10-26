import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:provider/provider.dart';

class PaintUi extends StatelessWidget {
  const PaintUi({super.key});

  @override
  Widget build(BuildContext context) {
    final paintModel = context.watch<PaintModel>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Undo',
                    icon: const Icon(Icons.undo),
                    iconSize: 40,
                    onPressed: paintModel.canUndo ? paintModel.undo : null,
                  ),
                  IconButton(
                    tooltip: 'Clear canvas',
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 40,
                    onPressed: paintModel.hasStrokes ? paintModel.clear : null,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.done),
                iconSize: 40,
                onPressed: () {
                  // TODO: export image
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
