import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// UI for the paint screen.
class PaintUi extends StatelessWidget {
  // callbacks for UI buttons; if you add any buttons pass their callbacks here.
  // this level of abstraction may be unnecessary but to keep things consistent try not to reference the model directly.
  final bool canUndo;
  final bool hasStrokes;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool isExporting;
  final VoidCallback onDone;

  const PaintUi({
    super.key,
    required this.canUndo,
    required this.hasStrokes,
    required this.onUndo,
    required this.onClear,
    required this.isExporting,
    required this.onDone,
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
                if (context.canPop()) {
                  context.pop();
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
                onPressed: isExporting ? null : onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
