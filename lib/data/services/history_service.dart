import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> logEvent(String uid, String type, Map<String, dynamic> meta) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('history')
        .add({
      'type': type,
      'meta': meta,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logToolUse(String uid, String toolName) async {
    await logEvent(uid, 'tool_use', {'tool': toolName});
  }

  Future<void> logSearch(String uid, String query) async {
    await logEvent(uid, 'search', {'query': query});
  }

  Future<void> logNavigation(String uid, String destination) async {
    await logEvent(uid, 'navigate', {'to': destination});
  }
}
