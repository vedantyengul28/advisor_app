import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveMessage(ChatMessage message) async {
    await _db.collection('chats').add(message.toMap());
  }

  Future<List<ChatMessage>> fetchMessages(String userId) async {
    final query = await _db
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt')
        .get();
    return query.docs
        .map((d) => ChatMessage.fromMap(d.data()))
        .toList();
  }
}
