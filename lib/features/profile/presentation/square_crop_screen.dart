import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

// widget for cropping the profile picture
class SquareCropScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const SquareCropScreen({super.key, required this.imageBytes});

  @override
  State<SquareCropScreen> createState() => _SquareCropScreenState();
}

class _SquareCropScreenState extends State<SquareCropScreen> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  bool _isProcessing = false;
  double _imageWidth = 0;
  double _imageHeight = 0;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.imageBytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imageWidth = frame.image.width.toDouble();
          _imageHeight = frame.image.height.toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error decoding image dimensions: $e');
    }
  }

  Future<void> _confirmCrop() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null && mounted) {
        final Uint8List croppedBytes = byteData.buffer.asUint8List();
        if (context.canPop()) {
          context.pop(croppedBytes);
        } else {
          Navigator.of(context).pop(croppedBytes);
        }
      }
    } catch (e) {
      debugPrint('Error cropping profile picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final squareSize = screenSize.width * 0.85;

    if (_imageWidth == 0 || _imageHeight == 0) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final double ar = _imageWidth / _imageHeight;
    final double maxDisplayWidth = screenSize.width * 0.85;
    final double maxDisplayHeight = screenSize.height * 0.6;

    late double displayW, displayH;
    if (maxDisplayWidth / ar <= maxDisplayHeight) {
      displayW = maxDisplayWidth;
      displayH = displayW / ar;
    } else {
      displayH = maxDisplayHeight;
      displayW = displayH * ar;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Position Profile Picture',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white, size: 30),
            onPressed: _isProcessing ? null : _confirmCrop,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Move with 1 finger & pinch to zoom with 2 fingers',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: squareSize,
              height: squareSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    width: squareSize,
                    height: squareSize,
                    child: ValueListenableBuilder<Matrix4>(
                      valueListenable: _transformationController,
                      builder: (context, matrix, _) {
                        return Transform(
                          transform: matrix,
                          child: SizedBox(
                            width: displayW,
                            height: displayH,
                            child: Opacity(
                              opacity: 0.4,
                              child: Image.memory(
                                widget.imageBytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: RepaintBoundary(
                      key: _cropKey,
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                width: squareSize,
                                height: squareSize,
                                child: ValueListenableBuilder<Matrix4>(
                                  valueListenable: _transformationController,
                                  builder: (context, matrix, _) {
                                    return Transform(
                                      transform: matrix,
                                      child: SizedBox(
                                        width: displayW,
                                        height: displayH,
                                        child: Image.memory(
                                          widget.imageBytes,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      constrained: false,
                      clipBehavior: Clip.none,
                      minScale: 0.5,
                      maxScale: 4.0,
                      boundaryMargin: EdgeInsets.all(squareSize * 2),
                      child: SizedBox(width: displayW, height: displayH),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
