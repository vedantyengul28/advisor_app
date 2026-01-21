import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageUploader {
  Future<TaskSnapshot> uploadXFile(Reference ref, XFile file) async {
    return await ref.putFile(File(file.path));
  }
}
