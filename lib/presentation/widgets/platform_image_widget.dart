import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'platform_image_impl_io.dart'
    if (dart.library.html) 'platform_image_impl_web.dart';

class PlatformImage extends StatelessWidget {
  final XFile file;
  final BoxFit? fit;
  final double? height;
  final double? width;

  const PlatformImage.xfile(
    this.file, {
    super.key,
    this.fit,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformImageImpl().fromXFile(
      file,
      fit: fit,
      height: height,
      width: width,
    );
  }
}

