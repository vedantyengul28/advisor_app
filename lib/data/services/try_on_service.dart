import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import 'package:image_picker/image_picker.dart';
import '../models/try_on_model.dart';

class TryOnService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final List<String> _clothIds = ['shirt1', 'shirt2', 'shirt3'];
  static int _nextIndex = 0;

  String _nextClothId() {
    final id = _clothIds[_nextIndex];
    _nextIndex = (_nextIndex + 1) % _clothIds.length;
    return id;
  }

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

  Future<String> generateTryOn({
    required String uid,
    required XFile userImage,
    String? clothId,
  }) async {
    final base = ApiConfig.baseUrl;
    if (base.isEmpty) {
      throw Exception('Try-On API is not configured');
    }
    final uri = Uri.parse('$base/try-on');
    final bytes = await userImage.readAsBytes();
    final req = http.MultipartRequest('POST', uri)
      ..fields['userId'] = uid
      ..fields['cloth_id'] = clothId ?? _nextClothId()
      ..files.add(http.MultipartFile.fromBytes('user_image', bytes, filename: userImage.name));
    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode != 200) {
      throw Exception('Try-On API error: ${res.statusCode}');
    }
    final json = res.body;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final out = map['generated_tryon_image'] as String?;
      if (out == null || out.isEmpty) {
        throw Exception('Invalid try-on response');
      }
      return out;
    } catch (_) {
      // Fall back to returning raw body
      return json;
    }
  }
}
