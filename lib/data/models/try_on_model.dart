class TryOnRecord {
  final String userId;
  final String? imageUrl;
  final double? heightCm;
  final double? weightKg;
  final String? bodyType;
  final DateTime createdAt;

  TryOnRecord({
    required this.userId,
    this.imageUrl,
    this.heightCm,
    this.weightKg,
    this.bodyType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bodyType': bodyType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TryOnRecord.fromMap(Map<String, dynamic> map) {
    return TryOnRecord(
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'],
      heightCm: map['heightCm'] != null ? (map['heightCm'] as num).toDouble() : null,
      weightKg: map['weightKg'] != null ? (map['weightKg'] as num).toDouble() : null,
      bodyType: map['bodyType'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
