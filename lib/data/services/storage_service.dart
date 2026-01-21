import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFeatureImage(String uid, String feature, XFile file) async {
    final path = 'users/$uid/$feature/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(File(file.path));
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }
}
