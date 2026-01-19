import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserProfile user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserProfile?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(uid).set(fields, SetOptions(merge: true));
  }

  Stream<UserProfile?> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    // Placeholder: implementation would query 'orders' where userId == userId
    return [];
  }

  Future<void> saveTryOn(Map<String, dynamic> tryOnData) async {
    await _db.collection('tryons').add(tryOnData);
  }

  Future<void> saveChat(Map<String, dynamic> chatData) async {
    await _db.collection('chats').add(chatData);
  }
}
