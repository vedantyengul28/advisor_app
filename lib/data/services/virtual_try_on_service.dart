import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class VirtualTryOnResult {
  final double leftPercent;
  final double topPercent;
  final double widthPercent;
  final double heightPercent;
  final Uint8List? compositeBytes;
  const VirtualTryOnResult({
    required this.leftPercent,
    required this.topPercent,
    required this.widthPercent,
    required this.heightPercent,
    this.compositeBytes,
  });
}

class VirtualTryOnService {
  Future<VirtualTryOnResult> process({
    required XFile userImage,
    required XFile clothingImage,
  }) async {
    // Placeholder alignment: center torso region
    return const VirtualTryOnResult(
      leftPercent: 0.25, // (1 - 0.5) / 2
      topPercent: 0.30,
      widthPercent: 0.50,
      heightPercent: 0.40,
      compositeBytes: null,
    );
  }
}

