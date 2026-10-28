import 'package:flutter/material.dart';

// UI for the paint screen.
class PaintUi extends StatelessWidget {
  // callbacks for UI buttons; if you add any buttons pass their callbacks here.
  // this level of abstraction may be unnecessary but to keep things consistent try not to reference the model directly.
  final bool canUndo;
  final bool hasStrokes;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  const PaintUi({
    super.key,
    required this.canUndo,
    required this.hasStrokes,
    required this.onUndo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            IconButton(
              tooltip: 'Back',
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
                    onPressed: canUndo ? onUndo : null,
                  ),
                  IconButton(
                    tooltip: 'Clear canvas',
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 40,
                    onPressed: hasStrokes ? onClear : null,
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
