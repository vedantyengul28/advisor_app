import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class TryOnCameraScreen extends StatefulWidget {
  final String assetShirtPath;
  const TryOnCameraScreen({super.key, this.assetShirtPath = 'assets/shirts/shirt1.png'});

  @override
  State<TryOnCameraScreen> createState() => _TryOnCameraScreenState();
}

class _TryOnCameraScreenState extends State<TryOnCameraScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _error;

  // Overlay controls
  double _scale = 1.0;
  Offset _offset = Offset.zero; // From center

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() {
        _initializing = false;
        _error = 'Try-On not supported on Web';
      });
      return;
    }
    try {
      final cams = await availableCameras();
      // Prefer front camera
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.isNotEmpty ? cams.first : throw CameraException('no_camera', 'No cameras found'),
      );
      final controller = CameraController(front, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await controller.initialize();
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } on CameraException catch (e) {
      setState(() {
        _error = e.code == 'CameraAccessDenied' ? 'Camera permission denied' : 'Camera error: ${e.description ?? e.code}';
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to initialize camera';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Stack(
          children: [
            Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
            Positioned(
              top: 40,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      );
    }
    final preview = _controller == null ? const SizedBox.shrink() : CameraPreview(_controller!);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: preview),

          // Shirt overlay: center the image, allow drag
          LayoutBuilder(
            builder: (context, constraints) {
              final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
              final pos = center + _offset;
              final shirtWidth = constraints.maxWidth * 0.6 * _scale;
              final shirtHeight = shirtWidth * 0.8; // approximate shirt aspect
              return Positioned(
                left: pos.dx - shirtWidth / 2,
                top: pos.dy - (constraints.maxHeight * 0.18), // bias upward toward chest area
                width: shirtWidth,
                height: shirtHeight,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() => _offset += d.delta),
                  child: Image.asset(widget.assetShirtPath, fit: BoxFit.contain),
                ),
              );
            },
          ),

          // Top-close button
          Positioned(
            top: 40,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Scale slider
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Row(
              children: [
                const Icon(Icons.zoom_out, color: Colors.white),
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (v) => setState(() => _scale = v),
                  ),
                ),
                const Icon(Icons.zoom_in, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

