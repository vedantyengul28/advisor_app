import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PlatformImageImpl {
  Widget fromXFile(XFile file, {BoxFit? fit, double? height, double? width}) {
    return FutureBuilder(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final bytes = snapshot.data as List<int>;
        return Image.memory(
          bytes as dynamic,
          fit: fit,
          height: height,
          width: width,
        );
      },
    );
  }
}

