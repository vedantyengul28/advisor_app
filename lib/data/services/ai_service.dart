import 'package:cloud_firestore/cloud_firestore.dart';

class AiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> analyzeStyle(String uid, {String? imageUrl}) async {
    final data = {
      if (imageUrl != null) 'imageUrl': imageUrl,
      'analysis':
          'Your palette suits deep navy, charcoal, olive, and earthy neutrals. Avoid neon and overly saturated tones.',
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(uid).collection('ai_results').doc('style_advisor').set(
          data,
          SetOptions(merge: true),
        );
  }

  Future<void> analyzeBodyShape(String uid, {String? imageUrl}) async {
    final data = {
      if (imageUrl != null) 'imageUrl': imageUrl,
      'shape': 'Rectangle',
      'notes':
          'Balance proportions with structured shoulders and defined waist. Layering helps add dimension.',
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(uid).collection('ai_results').doc('body_shape').set(
          data,
          SetOptions(merge: true),
        );
  }

  Future<void> analyzeHairstyle(String uid, {String? imageUrl}) async {
    final suggestions = [
      'Textured crop for easy daily styling',
      'Side-part with subtle fade to frame face',
      'Medium-length layers to add movement',
    ];
    final data = {
      if (imageUrl != null) 'imageUrl': imageUrl,
      'suggestions': suggestions,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(uid).collection('ai_results').doc('hairstyle').set(
          data,
          SetOptions(merge: true),
        );
  }

  Future<void> getOutfitSuggestions(
    String uid, {
    String? gender,
    String? bodyShape,
    List<String>? brands,
  }) async {
    final baseMale = [
      'Slim-fit navy blazer',
      'White oxford shirt',
      'Dark denim or tailored chinos',
      'Minimal leather sneakers',
    ];
    final baseFemale = [
      'A-line midi dress',
      'Tailored blazer',
      'High-rise straight jeans',
      'Ankle boots or minimalist sneakers',
    ];
    final selected = (gender?.toLowerCase() == 'male') ? baseMale : baseFemale;
    final branded = (brands == null || brands.isEmpty)
        ? selected
        : selected.map((s) => '${brands.first} $s').toList();
    final data = {
      'inputs': {
        if (gender != null) 'gender': gender,
        if (bodyShape != null) 'bodyShape': bodyShape,
        if (brands != null) 'brands': brands,
      },
      'suggestions': branded,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(uid).collection('ai_results').doc('outfits').set(
          data,
          SetOptions(merge: true),
        );
  }

  Future<void> getGroomingTips(String uid) async {
    final tips = [
      'Maintain a simple skincare routine: cleanse, moisturize, SPF.',
      'Trim facial hair regularly for a neat look.',
      'Choose fragrances with subtle, clean notes.',
      'Keep nails clean and trimmed.',
      'Match belt and shoes for a polished appearance.',
    ];
    final data = {
      'tips': tips,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(uid).collection('ai_results').doc('grooming').set(
          data,
          SetOptions(merge: true),
        );
  }
}
