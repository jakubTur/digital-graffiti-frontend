import 'package:flutter/material.dart';
import 'package:frontend/features/drawing/data/paint_model.dart';
import 'package:frontend/features/drawing/presentation/canvas_background_image.dart';
import 'package:frontend/features/drawing/presentation/paint_canvas.dart';
import 'package:frontend/features/drawing/presentation/paint_gesture_surface.dart';
import 'package:frontend/features/drawing/presentation/paint_ui.dart';
import 'package:provider/provider.dart';

// main class for the paint screen.
// wires together all the other paint-related widgets with the model that manages their state.
class PaintScreen extends StatelessWidget {
  final String? imagePath;
  const PaintScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey(imagePath),
      create: (_) => PaintModel(), // << use this model in a widget to interact with canvas state
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CanvasBackgroundImage(
                          imagePath: imagePath,
                          paintModel: paintModel,
                        ),
                        PaintCanvas(paintModel: paintModel, size: canvasSize),
                      ],
                    ),
                  ),
                ),
                Consumer<PaintModel>(
                  builder: (context, model, _) => PaintUi(
                    canUndo: model.canUndo,
                    hasStrokes: model.hasStrokes,
                    onUndo: model.undo,
                    onClear: model.clear,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
