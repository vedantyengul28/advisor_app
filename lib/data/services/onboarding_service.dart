import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> markStep(String uid, String step, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('onboarding').doc(step).set({
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> markComplete(String uid) async {
    await _db.collection('users').doc(uid).collection('onboarding').doc('_complete').set({
      'done': true,
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<bool> isComplete(String uid) async {
    final doc = await _db.collection('users').doc(uid).collection('onboarding').doc('_complete').get();
    final data = doc.data() as Map<String, dynamic>?;
    return (data?['done'] == true);
  }
}

