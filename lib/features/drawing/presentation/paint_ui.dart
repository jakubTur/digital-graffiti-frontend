import 'package:flutter/material.dart';
import 'package:frontend/core/icons/phosphor_icons.dart';
import 'package:frontend/features/drawing/presentation/state/brush_settings.dart';
import 'package:frontend/features/drawing/domain/entities/brushes/brush.dart';
import 'package:frontend/features/drawing/presentation/brush_picker.dart';
import 'package:frontend/features/drawing/presentation/brush_width_slider.dart';
import 'package:frontend/features/drawing/presentation/color_palette.dart';
import 'package:frontend/features/drawing/presentation/tool_drawer.dart';
import 'package:go_router/go_router.dart';

enum _Menu { brush, color, width }

// UI for the paint screen.
class PaintUi extends StatefulWidget {
  // callbacks for UI buttons; if you add any buttons pass their callbacks here.
  // this level of abstraction may be unnecessary but to keep things consistent try not to reference the model directly.
  final bool canUndo;
  final bool hasStrokes;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool isExporting;
  final VoidCallback onDone;
  final Brush brush;
  final bool isErasing;
  final Color color;
  final double width;
  final ValueChanged<Brush> onBrushChanged;
  final ValueChanged<bool> onErasingChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;

  const PaintUi({
    super.key,
    required this.canUndo,
    required this.hasStrokes,
    required this.onUndo,
    required this.onClear,
    required this.isExporting,
    required this.onDone,
    required this.brush,
    required this.isErasing,
    required this.color,
    required this.width,
    required this.onBrushChanged,
    required this.onErasingChanged,
    required this.onColorChanged,
    required this.onWidthChanged,
  });

  @override
  State<PaintUi> createState() => _PaintUiState();
}

class _PaintUiState extends State<PaintUi> {
  static const _iconSize = 28.0;
  static const _minWidthDot = 4.0;

  _Menu? _openMenu;

  void _toggle(_Menu menu) =>
      setState(() => _openMenu = _openMenu == menu ? null : menu);

  void _close() => setState(() => _openMenu = null);

  ValueChanged<T> _thenClose<T>(ValueChanged<T> callback) => (value) {
    callback(value);
    _close();
  };

  double get _widthDotDiameter {
    final fraction =
        (widget.width - BrushSettings.minWidth) /
        (BrushSettings.maxWidth - BrushSettings.minWidth);
    return _minWidthDot + fraction * (_iconSize - _minWidthDot);
  }

  Widget? get _drawerContent => switch (_openMenu) {
    _Menu.brush => BrushPicker(
      selectedBrush: widget.brush,
      onBrushSelected: _thenClose(widget.onBrushChanged),
    ),
    _Menu.color => ColorPalette(
      selectedColor: widget.color,
      onColorSelected: _thenClose(widget.onColorChanged),
    ),
    _Menu.width => BrushWidthSlider(
      width: widget.width,
      onChanged: widget.onWidthChanged,
      onChangeEnd: (_) => _close(),
    ),
    null => null,
  };

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_openMenu != null)
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _close(),
        ),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              tooltip: 'Back',
              iconSize: 40,
              icon: const Icon(
                PhosphorIconsRegular.arrowLeft,
                color: Colors.black,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToolDrawer(child: _drawerContent),
            _buildBottomBar(),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomBar() => Material(
    elevation: 8,
    color: Colors.deepPurple,
    child: SafeArea(
      top: false,
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: ButtonStyle(
            iconSize: const WidgetStatePropertyAll(_iconSize),
            visualDensity: VisualDensity.compact,
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? Colors.white38
                  : Colors.white,
            ),
            // highlight for the selected tool / open menu
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? Colors.white24 : null,
            ),
            overlayColor: const WidgetStatePropertyAll(Colors.white12),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Undo',
              icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise),
              onPressed: widget.canUndo ? widget.onUndo : null,
            ),
            IconButton(
              tooltip: 'Clear canvas',
              icon: const Icon(PhosphorIconsRegular.trash),
              onPressed: widget.hasStrokes ? widget.onClear : null,
            ),
            const Spacer(),
            _buildMenuButton(_Menu.brush, 'Brush', Icon(widget.brush.icon)),
            IconButton(
              tooltip: 'Eraser',
              icon: const Icon(PhosphorIconsRegular.eraser),
              isSelected: widget.isErasing,
              onPressed: () => widget.onErasingChanged(!widget.isErasing),
            ),
            _buildMenuButton(
              _Menu.color,
              'Color',
              _Dot(color: widget.color, diameter: _iconSize),
              enabled: !widget.isErasing,
            ),
            _buildMenuButton(
              _Menu.width,
              'Width',
              _Dot(color: Colors.white, diameter: _widthDotDiameter),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Done',
              icon: const Icon(PhosphorIconsRegular.check),
              onPressed: widget.isExporting ? null : widget.onDone,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildMenuButton(
    _Menu menu,
    String tooltip,
    Widget icon, {
    bool enabled = true,
  }) => IconButton(
    tooltip: tooltip,
    icon: SizedBox.square(
      dimension: _iconSize,
      child: Center(
        child: Opacity(opacity: enabled ? 1 : 0.38, child: icon),
      ),
    ),
    isSelected: _openMenu == menu,
    onPressed: enabled ? () => _toggle(menu) : null,
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  final double diameter;

  const _Dot({required this.color, required this.diameter});

  @override
  Widget build(BuildContext context) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white70),
    ),
  );
}
