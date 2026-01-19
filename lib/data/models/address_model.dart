class Address {
  final String? id;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String? label;

  Address({
    this.id,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'label': label,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map, {String? id}) {
    return Address(
      id: id,
      line1: map['line1'] ?? '',
      line2: map['line2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
      country: map['country'] ?? '',
      label: map['label'],
    );
  }
}
