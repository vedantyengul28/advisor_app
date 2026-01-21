import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'storage_upload_impl_io.dart'
    if (dart.library.html) 'storage_upload_impl_web.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFeatureImage(String uid, String feature, XFile file) async {
    final path = 'users/$uid/$feature/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref().child(path);
    final snap = await StorageUploader().uploadXFile(ref, file);
    final url = await snap.ref.getDownloadURL();
    return url;
  }
}
