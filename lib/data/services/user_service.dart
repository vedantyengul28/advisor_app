import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isProfileComplete(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final profile = UserProfile.fromMap(data);
    final hasCore = profile.name.isNotEmpty &&
        profile.email.isNotEmpty &&
        profile.gender.isNotEmpty &&
        profile.stylePreference.isNotEmpty &&
        (profile.occupation?.isNotEmpty ?? false);
    final brandsSnap = await _db.collection('users').doc(uid).collection('brands').limit(1).get();
    return hasCore && brandsSnap.docs.isNotEmpty;
  }
}
