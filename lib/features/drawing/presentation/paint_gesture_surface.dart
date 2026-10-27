import 'package:flutter/material.dart';

// detects gestures and triggers appropriate functionalities:
// panning/zooming (two-finger gestures) or painting (one-finger).
// NOTE: this widget is big for its purpose but sadly necessary.
// normally, a GestureDetector for painting and an InteractiveViewer for camera control would be enough.
// HOWEVER, InteractiveViewer intercepts one-finger drags as panning, which is also the gesture we're using for painting.
// so, to solve that issue, this widget detects strokes and triggers the correct behaviour manually.
class PaintGestureSurface extends StatefulWidget {
  // scene properties and callbacks.
  final Size sceneSize;
  final Widget child;
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;
  final VoidCallback onStrokeEnd;
  final VoidCallback onStrokeCancel;

  const PaintGestureSurface({
    super.key,
    required this.sceneSize,
    required this.child,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
    required this.onStrokeCancel,
  });

  @override
  State<PaintGestureSurface> createState() => _PaintGestureSurfaceState();
}

class _PaintGestureSurfaceState extends State<PaintGestureSurface> {
  final _transform = TransformationController();
  final _pointers = <int>{}; // fingers
  int? _paintPointer;
  
  // for preventing accidental strokes being created if the user actually wants to zoom/pan
  Stopwatch? _strokeTimer;
  
  bool _multiPointerGesture = false;
  bool _panEnabled = false;

  // if user adds a second finger within this timeframe,
  // the gesture is changed to a pan and the stroke is canceled.
  static const _accidentalStrokeWindow = Duration(milliseconds: 250);

  Rect get _sceneBounds => Offset.zero & widget.sceneSize;

  void _startStroke(Offset position) {
    final point = _transform.toScene(position);
    if (!_sceneBounds.contains(point)) return;
    widget.onStrokeStart(point);
    _paintPointer = _pointers.first;
    _strokeTimer = Stopwatch()..start();
  }

  void _finishStroke() {
    if (_paintPointer == null) return;
    widget.onStrokeEnd();
    _paintPointer = null;
    _strokeTimer = null;
  }

  void _cancelStroke() {
    if (_paintPointer == null) return;
    widget.onStrokeCancel();
    _paintPointer = null;
    _strokeTimer = null;
  }

  // pan needs to be set explicitly to avoid
  void _setPanEnabled(bool enabled, {required bool rebuild}) {
    if (!rebuild && _panEnabled == enabled) return;
    setState(() => _panEnabled = enabled);
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    if (_pointers.length == 1) {
      _startStroke(event.localPosition);
      _setPanEnabled(false, rebuild: true);
    } else {
      _multiPointerGesture = true;
      if (_strokeTimer != null &&
          _strokeTimer!.elapsed <= _accidentalStrokeWindow) {
        _cancelStroke();
      }
      _setPanEnabled(true, rebuild: true);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointers.length != 1 ||
        _multiPointerGesture ||
        _paintPointer != event.pointer) {
      return;
    }

    final point = _transform.toScene(event.localPosition);
    if (_sceneBounds.contains(point)) {
      widget.onStrokeUpdate(point);
    } else {
      _finishStroke();
    }
  }

  void _onPointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_paintPointer == event.pointer) _finishStroke();
    if (_pointers.isEmpty) {
      _multiPointerGesture = false;
      _setPanEnabled(false, rebuild: true);
    } else if (_multiPointerGesture &&
        _paintPointer != null &&
        _pointers.contains(_paintPointer)) {
      _multiPointerGesture = false;
      _setPanEnabled(false, rebuild: true);
    } else if (_multiPointerGesture) {
      _setPanEnabled(true, rebuild: true);
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount > 1) {
      _multiPointerGesture = true;
    }
  }

  @override
  void dispose() {
    _finishStroke();
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.center,
    child: SizedBox.fromSize(
      size: widget.sceneSize,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        child: InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.001,
          panEnabled: _panEnabled,
          onInteractionUpdate: _onInteractionUpdate,
          child: SizedBox.fromSize(size: widget.sceneSize, child: widget.child),
        ),
      ),
    ),
  );
}
