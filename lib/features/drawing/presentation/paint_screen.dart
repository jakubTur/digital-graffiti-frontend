import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/presentation/state/brush_settings.dart';
import 'package:frontend/features/drawing/presentation/canvas_exporter.dart';
import 'package:frontend/features/drawing/presentation/state/paint_model.dart';
import 'package:frontend/features/drawing/presentation/canvas_background_image.dart';
import 'package:frontend/features/drawing/presentation/paint_canvas.dart';
import 'package:frontend/features/drawing/presentation/paint_gesture_surface.dart';
import 'package:frontend/features/drawing/presentation/paint_ui.dart';
import 'package:provider/provider.dart';

// main class for the paint screen.
// wires together all the other paint-related widgets with the model that manages their state.
class PaintScreen extends StatelessWidget {

  final List<ImageProvider> backgroundLayers;
  final bool exportWithBackground;

  // updates the canvas with the created image stored as raw bytes.
  final ValueChanged<Uint8List> onImageCreated;

  const PaintScreen({
    super.key,
    this.backgroundLayers = const [],
    this.exportWithBackground = false,
    required this.onImageCreated,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      key: ObjectKey(backgroundLayers),
      providers: [
        ChangeNotifierProvider(create: (_) => BrushSettings()),
        ChangeNotifierProvider(
          create: (context) => PaintModel(
            brushSettings: context.read<BrushSettings>(),
            exporter: CanvasExporter(),
            backgroundLayers: backgroundLayers,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final paintModel = context.read<PaintModel>();
          return Scaffold(
            body: Stack(
              children: [
                Selector<PaintModel, Size>(
                  selector: (_, model) => model.canvasSize,
                  builder: (context, canvasSize, _) => PaintGestureSurface(
                    sceneSize: canvasSize,
                    onStrokeStart: paintModel.beginStroke,
                    onStrokeUpdate: paintModel.extendStroke,
                    onStrokeEnd: paintModel.finishStroke,
                    onStrokeCancel: paintModel.cancelStroke,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CanvasBackgroundImage(paintModel: paintModel),
                        PaintCanvas(paintModel: paintModel, size: canvasSize),
                      ],
                    ),
                  ),
                ),
                Consumer2<PaintModel, BrushSettings>(
                  builder: (context, model, settings, _) => PaintUi(
                    canUndo: model.canUndo,
                    hasStrokes: model.hasStrokes,
                    onUndo: model.undo,
                    onClear: model.clear,
                    isExporting: model.isExporting,
                    onDone: () =>
                        _exportImage(context, paintModel, onImageCreated),
                    brush: settings.brush,
                    isErasing: settings.isErasing,
                    color: settings.color,
                    width: settings.width,
                    onBrushChanged: settings.setBrush,
                    onErasingChanged: settings.setErasing,
                    onColorChanged: settings.setColor,
                    onWidthChanged: settings.setWidth,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportImage(
    BuildContext context,
    PaintModel model,
    ValueChanged<Uint8List> onImageCreated,
  ) async {
    try {
      final image = await model.exportImage(
        includeBackground: exportWithBackground,
      );
      if (context.mounted) onImageCreated(image);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export post: $error')),
        );
      }
    }
  }
}
