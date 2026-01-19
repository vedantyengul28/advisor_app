import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';
import '../models/preference_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addOrUpdateAddress(String uid, Address address) async {
    final col = _db.collection('users').doc(uid).collection('addresses');
    if (address.id != null) {
      await col.doc(address.id).set(address.toMap(), SetOptions(merge: true));
    } else {
      await col.add(address.toMap());
    }
  }

  Future<List<Address>> listAddresses(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('addresses').get();
    return snap.docs.map((d) => Address.fromMap(d.data(), id: d.id)).toList();
  }

  Future<void> setPreferences(String uid, Preferences prefs) async {
    await _db.collection('users').doc(uid).collection('preferences').doc('default').set(
          prefs.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<Preferences?> getPreferences(String uid) async {
    final doc = await _db.collection('users').doc(uid).collection('preferences').doc('default').get();
    if (!doc.exists) return null;
    return Preferences.fromMap(doc.data() as Map<String, dynamic>);
  }
}
