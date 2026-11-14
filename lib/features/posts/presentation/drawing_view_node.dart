import 'package:flutter/material.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';

/// node that displays a drawing, all of its ancestors, and the post background in order from front to back.
/// used in the post tree.
class DrawingViewNode extends StatelessWidget {
  const DrawingViewNode({
    super.key,
    required this.drawing,
    required this.layers,
    required this.isOwn,
    required this.onDraw,
  });

  final Drawing drawing;
  final List<ImageProvider> layers;
  final bool isOwn;
  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 280,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwn ? Colors.green : Colors.grey,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            drawing.username,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: layers.isEmpty
                ? const Center(child: Icon(Icons.broken_image))
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      for (final layer in layers)
                        Image(
                          image: layer,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 4),
          Center(
            child: ElevatedButton.icon(
              onPressed: onDraw,
              icon: const Icon(Icons.brush),
              label: const Text('Draw'),
            ),
          ),
        ],
      ),
    );
  }
}
