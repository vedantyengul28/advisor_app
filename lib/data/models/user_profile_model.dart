class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final String stylePreference;
  final String role;
  final DateTime createdAt;
  final String? mobile;
  final String? occupation;
  final String? brands;
  final String? address;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.stylePreference,
    required this.role,
    required this.createdAt,
    this.mobile,
    this.occupation,
    this.brands,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'stylePreference': stylePreference,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'mobile': mobile,
      'occupation': occupation,
      'brands': brands,
      'address': address,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      stylePreference: map['stylePreference'] ?? '',
      role: map['role'] ?? 'Customer',
      createdAt: DateTime.parse(map['createdAt']),
      mobile: map['mobile'],
      occupation: map['occupation'],
      brands: map['brands'],
      address: map['address'],
    );
  }
}
