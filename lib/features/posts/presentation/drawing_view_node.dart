import 'package:flutter/material.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';

/// node that displays a drawing, all of its ancestors, and the post background in order from front to back.
/// used in the post tree.
class DrawingViewNode extends StatelessWidget {
  const DrawingViewNode({
    super.key,
    required this.drawing,
    required this.layers,
    required this.aspectRatio,
    required this.isOwn,
    required this.onDraw,
  });

  /// the currently previewed drawing object. get parents or post recursively.
  final Drawing drawing;

  /// images to render. from front to back: own drawing image, parent drawing images, post background.
  final List<ImageProvider> layers;

  /// aspect ratio. loaded from constructor so that this remains stateless.
  final double aspectRatio;

  /// if true, set the border color differently so the user can distinguish their own drawings.
  final bool isOwn;

  /// callback for the draw (comment) button.
  final VoidCallback onDraw;

  /// width size of node to display. combine with AspectRatio. image is scaled to fit.
  static const double _imageWidth = 220;

  /// style properties:
  static const double _borderWidth = 10;
  static const Radius _tabRadius = Radius.circular(20);
  static const double iconSize = 40;
  static const double textSize = 40;

  @override
  Widget build(BuildContext context) {
    final color = isOwn ? Colors.green : Colors.white;
    return SizedBox(
      width: _imageWidth + 2 * _borderWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: _imageWidth),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: _tabRadius),
              ),
              child: Text(
                drawing.username,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: Colors.black, fontSize: textSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: color, width: _borderWidth),
            ),
            child: SizedBox(
              width: _imageWidth,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: layers.isEmpty
                    ? const Center(child: Icon(Icons.broken_image))
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          for (final layer in layers)
                            Image(
                              image: layer,
                              fit: BoxFit.fill,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(bottom: _tabRadius),
              ),
              child: IconButton(
                tooltip: 'Draw',
                onPressed: onDraw,
                icon: const Icon(
                  Icons.edit_square,
                  color: Colors.black,
                  size: iconSize,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
