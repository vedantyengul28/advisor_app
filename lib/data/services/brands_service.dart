import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Brand>> getCatalog() async {
    final snap = await _db.collection('brand_catalog').orderBy('name').get();
    return snap.docs.map((d) => Brand.fromMap(d.data())).toList();
  }

  Future<void> setUserBrands(String uid, List<String> brandIds) async {
    final batch = _db.batch();
    final col = _db.collection('users').doc(uid).collection('brands');
    final existing = await col.get();
    for (final d in existing.docs) {
      batch.delete(d.reference);
    }
    for (final id in brandIds) {
      batch.set(col.doc(id), {'brandId': id, 'addedAt': DateTime.now().toIso8601String()});
    }
    await batch.commit();
  }

  Future<List<String>> getUserBrandIds(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('brands').get();
    return snap.docs.map((d) => d.id).toList();
  }
}
