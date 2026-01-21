import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlatformImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickCamera(BuildContext context) async {
    if (kIsWeb) {
      _notifyUnsupported(context, 'Camera is not available on web');
      return null;
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    }
    _notifyUnsupported(context, 'Camera is not available on this platform');
    return null;
  }

  Future<XFile?> pickGallery(BuildContext context) async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    }
    _notifyUnsupported(context, 'Gallery picker is not available on this platform');
    return null;
  }

  void _notifyUnsupported(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

