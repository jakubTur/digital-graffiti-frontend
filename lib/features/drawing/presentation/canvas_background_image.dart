import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/state/paint_model.dart';

// simple widget for displaying the background image.
// this is just here to keep PaintScreen clean and concise really.
// image is stored in paintModel because it's required for  the export functionality.
class CanvasBackgroundImage extends StatelessWidget {
  final PaintModel paintModel;

  const CanvasBackgroundImage({super.key, required this.paintModel});

  @override
  Widget build(BuildContext context) {
    final layers = paintModel.backgroundLayers;
    return SizedBox.fromSize(
      size: paintModel.canvasSize,
      child: layers.isEmpty
          ? null
          : Stack(
              fit: StackFit.expand,
              children: [
                for (final (index, layer) in layers.indexed)
                  Image(
                    image: layer,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    frameBuilder: index == 0 ? _sizeCanvasToImage : null,
                  ),
              ],
            ),
    );
  }

  Widget _sizeCanvasToImage(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    final image = (child as RawImage).image;
    if (image != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => paintModel.setBackgroundImage(image),
      );
    }
    return child;
  }
}
