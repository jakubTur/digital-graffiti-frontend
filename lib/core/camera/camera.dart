import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInitialized =
        cameraController != null && cameraController!.value.isInitialized;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: isInitialized
                ? CameraPreview(cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/map');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> availableCams = await availableCameras();
    if (availableCams.isNotEmpty) {
      cameraController = CameraController(
        availableCams.first,
        ResolutionPreset.high,
      );
      await cameraController?.initialize();
      if (mounted) {
        setState(() {
          cameras = availableCams;
        });
      }
    }
  }
}
