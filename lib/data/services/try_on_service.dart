import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/try_on_model.dart';

class TryOnService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecord(TryOnRecord record) async {
    await _db.collection('tryons').add(record.toMap());
  }

  Future<List<TryOnRecord>> fetchRecords(String userId) async {
    final query = await _db
        .collection('tryons')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs
        .map((d) => TryOnRecord.fromMap(d.data()))
        .toList();
  }
}
