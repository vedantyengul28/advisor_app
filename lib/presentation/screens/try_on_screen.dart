// // import 'package:flutter/material.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../widgets/glass_container.dart';
// // import '../widgets/custom_text_field.dart';
// // import '../widgets/gradient_button.dart';
// // import 'package:provider/provider.dart';
// // import '../../data/services/auth_service.dart';
// // import '../../data/services/try_on_service.dart';
// // import '../../data/models/try_on_model.dart';
// // import '../../data/services/history_service.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../../data/services/virtual_try_on_service.dart';
// // import 'dart:ui' as ui;
// // import 'package:flutter/rendering.dart';
// // import '../widgets/platform_image_widget.dart';
// // import '../../data/services/platform_image_picker_service.dart';

// // class TryOnScreen extends StatefulWidget {
// //   const TryOnScreen({super.key});

// //   @override
// //   State<TryOnScreen> createState() => _TryOnScreenState();
// // }

// // class _TryOnScreenState extends State<TryOnScreen> {
// //   bool _isProcessing = false;
// //   bool _isResultReady = false;
// //   final _heightController = TextEditingController();
// //   final _weightController = TextEditingController();
// //   final _bodyTypeController = TextEditingController();
// //   final TryOnService _tryOnService = TryOnService();
// //   final PlatformImagePickerService _platformPicker = PlatformImagePickerService();
// //   XFile? _userImage;
// //   XFile? _clothingImage;
// //   String? _error;
// //   final _tryOnAI = VirtualTryOnService();
// //   final GlobalKey _resultKey = GlobalKey();
// //   double? _leftPct;
// //   double? _topPct;
// //   double? _widthPct;
// //   double? _heightPct;

// //   void _processTryOn() async {
// //     if (_userImage == null || _clothingImage == null) {
// //       setState(() => _error = 'Please select your photo and a clothing image.');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Select both user photo and clothing image')),
// //       );
// //       return;
// //     }
// //     setState(() {
// //       _isProcessing = true;
// //       _error = null;
// //     });
// //     final result = await _tryOnAI.process(userImage: _userImage!, clothingImage: _clothingImage!);
// //     if (!mounted) return;
// //     setState(() {
// //       _leftPct = result.leftPercent;
// //       _topPct = result.topPercent;
// //       _widthPct = result.widthPercent;
// //       _heightPct = result.heightPercent;
// //       _isProcessing = false;
// //       _isResultReady = true;
// //     });
// //   }
  
// //   Future<void> _pickSource(void Function(XFile) onPicked) async {
// //     final choice = await showModalBottomSheet<String>(
// //       context: context,
// //       builder: (context) => Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(context, 'camera')),
// //           ListTile(leading: const Icon(Icons.image), title: const Text('Gallery'), onTap: () => Navigator.pop(context, 'gallery')),
// //         ],
// //       ),
// //     );
// //     if (choice == null) return;
// //     final img = choice == 'camera'
// //         ? await _platformPicker.pickCamera(context)
// //         : await _platformPicker.pickGallery(context);
// //     if (img != null) onPicked(img);
// //   }

// //   Future<void> _exportResult() async {
// //     try {
// //       final boundary = _resultKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// //       if (boundary == null) return;
// //       final image = await boundary.toImage(pixelRatio: 2);
// //       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //       final bytes = byteData?.buffer.asUint8List();
// //       if (bytes == null) return;
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview captured')));
// //     } catch (_) {
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to capture preview')));
// //     }
// //   }
// //   Future<void> _saveLook() async {
// //     final auth = Provider.of<AuthService>(context, listen: false);
// //     final uid = auth.currentUser?.uid;
// //     if (uid == null) return;
// //     final record = TryOnRecord(
// //       userId: uid,
// //       heightCm: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
// //       weightKg: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
// //       bodyType: _bodyTypeController.text.isNotEmpty ? _bodyTypeController.text : null,
// //       createdAt: DateTime.now(),
// //     );
// //     await _tryOnService.saveRecord(record);
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Saved to your looks')),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Virtual Try-On'),
// //         backgroundColor: Colors.transparent,
// //       ),
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: SingleChildScrollView(
// //             padding: const EdgeInsets.all(20),
// //             child: _isResultReady ? _buildResultView() : _buildInputForm(),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInputForm() {
// //     return Column(
// //       children: [
// //         GlassContainer(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             children: [
// //               const Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.white54),
// //               const SizedBox(height: 16),
// //               const Text('Upload Front Body Photo', style: TextStyle(color: Colors.white)),
// //               const SizedBox(height: 24),
// //               OutlinedButton(
// //                 onPressed: () async {
// //                   final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
// //                   if (uid == null) return;
// //                   await HistoryService().logEvent(uid, 'tryon', {'action': 'choose_user_image'});
// //                   await _pickSource((img) => setState(() => _userImage = img));
// //                 },
// //                 child: const Text('Choose Image'),
// //               ),
// //               const SizedBox(height: 12),
// //               OutlinedButton(
// //                 onPressed: () async {
// //                   final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
// //                   if (uid == null) return;
// //                   await HistoryService().logEvent(uid, 'tryon', {'action': 'choose_clothing_image'});
// //                   await _pickSource((img) => setState(() => _clothingImage = img));
// //                 },
// //                 child: const Text('Choose Clothing'),
// //               ),
// //               const SizedBox(height: 16),
// //               if (_userImage != null)
// //                 Column(
// //                   children: [
// //                     const Text('Selected Photo', style: TextStyle(color: Colors.white70)),
// //                     const SizedBox(height: 8),
// //                     PlatformImage.xfile(_userImage!, height: 160, fit: BoxFit.cover),
// //                   ],
// //                 ),
// //               const SizedBox(height: 12),
// //               if (_clothingImage != null)
// //                 Column(
// //                   children: [
// //                     const Text('Selected Clothing', style: TextStyle(color: Colors.white70)),
// //                     const SizedBox(height: 8),
// //                     PlatformImage.xfile(_clothingImage!, height: 120, fit: BoxFit.contain),
// //                   ],
// //                 ),
// //               if (_error != null) ...[
// //                 const SizedBox(height: 12),
// //                 Text(_error!, style: const TextStyle(color: Colors.redAccent)),
// //               ],
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 24),
// //         CustomTextField(hintText: 'Height (cm)', controller: _heightController),
// //         const SizedBox(height: 16),
// //         CustomTextField(hintText: 'Weight (kg)', controller: _weightController),
// //         const SizedBox(height: 16),
// //         CustomTextField(hintText: 'Body Type (e.g. Hourglass)', controller: _bodyTypeController),
// //         const SizedBox(height: 32),
// //         GradientButton(
// //           text: 'Generate Try-On',
// //           onPressed: _processTryOn,
// //           isLoading: _isProcessing,
// //           colors: const [AppColors.shipping, Color(0xFF42A5F5)],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildResultView() {
// //     return Column(
// //       children: [
// //         const Text('AI Try-On Result', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
// //         const SizedBox(height: 24),
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 children: [
// //                   Container(
// //                     height: 220,
// //                     decoration: BoxDecoration(
// //                       color: Colors.black.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: _userImage == null
// //                         ? const Center(child: Text('Original'))
// //                         : ClipRRect(
// //                             borderRadius: BorderRadius.circular(12),
// //                             child: PlatformImage.xfile(_userImage!, fit: BoxFit.cover),
// //                           ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 16),
// //              Expanded(
// //               child: Column(
// //                 children: [
// //                   RepaintBoundary(
// //                     key: _resultKey,
// //                     child: Container(
// //                     height: 220,
// //                     decoration: BoxDecoration(
// //                       color: Colors.black.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: _userImage == null
// //                         ? const Center(child: Text('Simulated'))
// //                         : ClipRRect(
// //                             borderRadius: BorderRadius.circular(12),
// //                             child: LayoutBuilder(
// //                               builder: (context, constraints) {
// //                                 final w = constraints.maxWidth;
// //                                 final h = constraints.maxHeight;
// //                                 final torsoWidth = w * (_widthPct ?? 0.5);
// //                                 final torsoHeight = h * (_heightPct ?? 0.4);
// //                                 final torsoLeft = w * (_leftPct ?? 0.25);
// //                                 final torsoTop = h * (_topPct ?? 0.30);
// //                                 return Stack(
// //                                   children: [
// //                                     Positioned.fill(
// //                                       child: PlatformImage.xfile(
// //                                         _userImage!,
// //                                         fit: BoxFit.cover,
// //                                       ),
// //                                     ),
// //                                     if (_clothingImage != null)
// //                                       Positioned(
// //                                         left: torsoLeft,
// //                                         top: torsoTop,
// //                                         width: torsoWidth,
// //                                         height: torsoHeight,
// //                                         child: PlatformImage.xfile(
// //                                           _clothingImage!,
// //                                           fit: BoxFit.contain,
// //                                         ),
// //                                       ),
// //                                   ],
// //                                 );
// //                               },
// //                             ),
// //                           ),
// //                   ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 32),
// //         GradientButton(
// //           text: 'Save Look',
// //           onPressed: () async {
// //             await _exportResult();
// //             await _saveLook();
// //           },
// //           colors: const [AppColors.shipping, Color(0xFF42A5F5)],
// //         ),
// //         const SizedBox(height: 16),
// //          TextButton(
// //           onPressed: () {
// //             setState(() {
// //               _isResultReady = false;
// //               _userImage = null;
// //               _clothingImage = null;
// //               _error = null;
// //             });
// //           },
// //           child: const Text('Retake'),
// //         ),
// //       ],
// //     );
// //   }
// // }

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// import '../../core/constants/app_colors.dart';
// import '../widgets/glass_container.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/gradient_button.dart';

// import '../../data/services/auth_service.dart';
// import '../../data/services/try_on_service.dart';
// import '../../data/models/try_on_model.dart';
// import '../../data/services/history_service.dart';

// class TryOnScreen extends StatefulWidget {
//   const TryOnScreen({super.key});

//   @override
//   State<TryOnScreen> createState() => _TryOnScreenState();
// }

// class _TryOnScreenState extends State<TryOnScreen> {
//   bool _isProcessing = false;
//   bool _isResultReady = false;

//   final _heightController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _bodyTypeController = TextEditingController();

//   final TryOnService _tryOnService = TryOnService();
//   final ImagePicker _picker = ImagePicker();

//   XFile? _userImage;
//   XFile? _clothingImage;
//   String? _error;

//   // ---------------- IMAGE WIDGET (WEB + MOBILE SAFE)
//   Widget _buildImage(XFile file, {double? height, BoxFit fit = BoxFit.cover}) {
//     if (kIsWeb) {
//       return Image.network(file.path, height: height, fit: fit);
//     } else {
//       return Image.asset(
//         file.path,
//         height: height,
//         fit: fit,
//         errorBuilder: (_, __, ___) =>
//             const Icon(Icons.broken_image, color: Colors.white54),
//       );
//     }
//   }

//   void _processTryOn() {
//     if (_userImage == null || _clothingImage == null) {
//       setState(() => _error = 'Please select both images');
//       return;
//     }

//     setState(() {
//       _isProcessing = true;
//       _error = null;
//     });

//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
//       setState(() {
//         _isProcessing = false;
//         _isResultReady = true;
//       });
//     });
//   }

//   Future<void> _saveLook() async {
//     final auth = Provider.of<AuthService>(context, listen: false);
//     final uid = auth.currentUser?.uid;
//     if (uid == null) return;

//     final record = TryOnRecord(
//       userId: uid,
//       heightCm: double.tryParse(_heightController.text),
//       weightKg: double.tryParse(_weightController.text),
//       bodyType: _bodyTypeController.text,
//       createdAt: DateTime.now(),
//     );

//     await _tryOnService.saveRecord(record);

//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Saved to your looks')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Virtual Try-On'),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: _isResultReady ? _buildResultView() : _buildInputForm(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputForm() {
//     return Column(
//       children: [
//         GlassContainer(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const Icon(
//                 Icons.cloud_upload_outlined,
//                 size: 60,
//                 color: Colors.white54,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Upload Images',
//                 style: TextStyle(color: Colors.white),
//               ),
//               const SizedBox(height: 20),

//               OutlinedButton(
//                 onPressed: () async {
//                   final img = await _picker.pickImage(
//                     source: ImageSource.gallery,
//                     imageQuality: 85,
//                   );
//                   if (img != null) setState(() => _userImage = img);
//                 },
//                 child: const Text('Choose Body Photo'),
//               ),

//               const SizedBox(height: 12),

//               OutlinedButton(
//                 onPressed: () async {
//                   final img = await _picker.pickImage(
//                     source: ImageSource.gallery,
//                     imageQuality: 85,
//                   );
//                   if (img != null) setState(() => _clothingImage = img);
//                 },
//                 child: const Text('Choose Clothing'),
//               ),

//               if (_userImage != null) ...[
//                 const SizedBox(height: 16),
//                 _buildImage(_userImage!, height: 160),
//               ],

//               if (_clothingImage != null) ...[
//                 const SizedBox(height: 12),
//                 _buildImage(_clothingImage!, height: 120, fit: BoxFit.contain),
//               ],

//               if (_error != null) ...[
//                 const SizedBox(height: 12),
//                 Text(_error!, style: const TextStyle(color: Colors.redAccent)),
//               ],
//             ],
//           ),
//         ),

//         const SizedBox(height: 24),
//         CustomTextField(hintText: 'Height (cm)', controller: _heightController),
//         const SizedBox(height: 16),
//         CustomTextField(hintText: 'Weight (kg)', controller: _weightController),
//         const SizedBox(height: 16),
//         CustomTextField(hintText: 'Body Type', controller: _bodyTypeController),

//         const SizedBox(height: 32),
//         GradientButton(
//           text: 'Generate Try-On',
//           isLoading: _isProcessing,
//           onPressed: _processTryOn,
//           colors: const [AppColors.shipping, Color(0xFF42A5F5)],
//         ),
//       ],
//     );
//   }

//   Widget _buildResultView() {
//     return Column(
//       children: [
//         const Text(
//           'AI Try-On Result',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 24),

//         Row(
//           children: [
//             Expanded(child: _buildImage(_userImage!, height: 220)),
//             const SizedBox(width: 16),
//             Expanded(child: _buildImage(_clothingImage!, height: 220)),
//           ],
//         ),

//         const SizedBox(height: 32),
//         GradientButton(
//           text: 'Save Look',
//           onPressed: _saveLook,
//           colors: const [AppColors.shipping, Color(0xFF42A5F5)],
//         ),

//         TextButton(
//           onPressed: () {
//             setState(() {
//               _isResultReady = false;
//               _userImage = null;
//               _clothingImage = null;
//             });
//           },
//           child: const Text('Retake'),
//         ),
//       ],
//     );
//   }
// }

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/gradient_button.dart';

class TryOnScreen extends StatefulWidget {

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  CameraController? _controller;
  bool _ready = false;
  int _shirtIndex = 0;
  final List<String> _shirts = const [
    'assets/shirts/shirt1.png',
    'assets/shirts/shirt2.png',
    'assets/shirts/shirt3.png',
  ];
  late final PoseDetector _poseDetector;
  bool _busy = false;
  DateTime _lastPoseTs = DateTime.fromMillisecondsSinceEpoch(0);
  Offset? _overlayCenter;
  double _overlayWidth = 0;
  double _overlayAngle = 0;

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      CameraDescription? front;
      for (final c in cams) {
        if (c.lensDirection == CameraLensDirection.front) {
          front = c;
          break;
        }
      }
      final desc = front ?? cams.first;
      final ctrl = CameraController(desc, ResolutionPreset.medium, enableAudio: false);
      await ctrl.initialize();
      if (!kIsWeb) {
        await ctrl.startImageStream(_onImage);
      }
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _ready = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ready = false;
      });
    }
  }

  @override
  void dispose() {
    _poseDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  InputImageRotation _rotationFromDegrees(int r) {
    switch (r % 360) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void _onImage(CameraImage image) async {
    if (_busy) return;
    final now = DateTime.now();
    if (now.difference(_lastPoseTs).inMilliseconds < 80) return;
    _busy = true;
    _lastPoseTs = now;
    try {
      final rotation = _rotationFromDegrees(_controller!.description.sensorOrientation);
      final format = image.format.group == ImageFormatGroup.bgra8888
          ? InputImageFormat.bgra8888
          : InputImageFormat.yuv420;
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      final inputImage = InputImage.fromBytes(bytes: image.planes[0].bytes, metadata: metadata);
      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        final pose = poses.first;
        final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
        final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
        final nose = pose.landmarks[PoseLandmarkType.nose];
        if (ls != null && rs != null && nose != null) {
          final imgW = image.width.toDouble();
          final imgH = image.height.toDouble();
          final size = MediaQuery.of(context).size;
          final scale = (size.width / imgW > size.height / imgH) ? size.width / imgW : size.height / imgH;
          final toScreen = (double x, double y) => Offset(
                (x - imgW / 2) * scale + size.width / 2,
                (y - imgH / 2) * scale + size.height / 2,
              );
          final l = toScreen(ls.x, ls.y);
          final r = toScreen(rs.x, rs.y);
          final n = toScreen(nose.x, nose.y);
          final shoulderDist = (r - l).distance;
          final center = Offset((l.dx + r.dx) / 2, (l.dy + r.dy) / 2);
          final width = shoulderDist * 1.2;
          double angle = (r - l).direction;
          final downOffset = shoulderDist * 0.4;
          Offset chest = Offset(center.dx, center.dy + downOffset);
          final minTop = n.dy + shoulderDist * 0.15;
          if (chest.dy < minTop) {
            chest = Offset(chest.dx, minTop);
          }
          setState(() {
            _overlayCenter = chest;
            _overlayWidth = width;
            _overlayAngle = angle;
          });
        }
      }
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildCameraOverlay(context),
    );
  }

  Widget _buildCameraOverlay(BuildContext context) {
    if (!_ready || _controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final size = MediaQuery.of(context).size;
    final shirtWidth = _overlayWidth > 0 ? _overlayWidth : size.width * 0.6;
    final previewSize = _controller!.value.previewSize;
    final previewW = previewSize?.width ?? size.width;
    final previewH = previewSize?.height ?? size.height;
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewW,
              height: previewH,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        Center(
          child: _overlayCenter == null
              ? Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    _shirts[_shirtIndex],
                    width: shirtWidth,
                    fit: BoxFit.contain,
                  ),
                )
              : Transform.translate(
                  offset: Offset(_overlayCenter!.dx - size.width / 2, _overlayCenter!.dy - size.height / 2),
                  child: Transform.rotate(
                    angle: _overlayAngle,
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        _shirts[_shirtIndex],
                        width: shirtWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: GradientButton(
            text: 'Change Shirt',
            isLoading: false,
            onPressed: () {
              setState(() {
                _shirtIndex = (_shirtIndex + 1) % _shirts.length;
              });
            },
            colors: const [AppColors.shipping, Color(0xFF42A5F5)],
          ),
        ),
      ],
    );
  }
}
