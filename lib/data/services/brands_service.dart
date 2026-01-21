import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Brand>> getCatalog() async {
    final snap = await _db.collection('brand_catalog').orderBy('name').get();
    final list = snap.docs.map((d) => Brand.fromMap(d.data())).toList();
    if (list.isNotEmpty) return list;
    final names = [
      "Levi's",
      'H&M',
      'Zara',
      'Adidas',
      'Nike',
      'Uniqlo',
      'Calvin Klein',
      'Tommy Hilfiger',
      'Allen Solly',
      'U.S. Polo Assn.',
      'W',
      'Biba',
      'AND',
      'Fabindia',
      'Pepe Jeans',
      'Roadster',
    ];
    String slug(String s) {
      final lower = s.toLowerCase();
      final cleaned = lower.replaceAll(RegExp(r"[^a-z0-9]+"), '_');
      return cleaned.replaceAll(RegExp(r"^_+|_+$"), '');
    }
    return names.map((n) => Brand(id: slug(n), name: n)).toList();
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

  Future<List<String>> getUserBrandNames(String uid) async {
    final ids = await getUserBrandIds(uid);
    if (ids.isEmpty) return const [];
    final catalog = await getCatalog();
    final byId = {for (final b in catalog) b.id: b.name};
    return ids.map((id) => byId[id] ?? id).toList();
  }
}
