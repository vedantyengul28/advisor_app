class Preferences {
  final List<String> styles;
  final List<String> options;

  Preferences({
    required this.styles,
    required this.options,
  });

  Map<String, dynamic> toMap() => {
        'styles': styles,
        'options': options,
      };

  factory Preferences.fromMap(Map<String, dynamic> map) => Preferences(
        styles: (map['styles'] as List?)?.cast<String>() ?? const [],
        options: (map['options'] as List?)?.cast<String>() ?? const [],
      );
}
