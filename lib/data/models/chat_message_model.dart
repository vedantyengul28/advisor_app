class ChatMessage {
  final String userId;
  final bool isUser;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.userId,
    required this.isUser,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isUser': isUser,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      userId: map['userId'] ?? '',
      isUser: map['isUser'] ?? false,
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
