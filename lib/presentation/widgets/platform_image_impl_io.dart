import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PlatformImageImpl {
  Widget fromXFile(XFile file, {BoxFit? fit, double? height, double? width}) {
    return Image.file(
      File(file.path),
      fit: fit,
      height: height,
      width: width,
    );
  }
}

