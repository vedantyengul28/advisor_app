class Brand {
  final String id;
  final String name;

  Brand({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Brand.fromMap(Map<String, dynamic> map) =>
      Brand(id: map['id'] ?? '', name: map['name'] ?? '');
}
