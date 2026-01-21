import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageUploader {
  Future<TaskSnapshot> uploadXFile(Reference ref, XFile file) async {
    final bytes = await file.readAsBytes();
    return await ref.putData(bytes);
  }
}
