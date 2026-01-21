import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

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

  Future<String> askStyleAdvisor(String uid, String question) async {
    final useBase = ApiConfig.baseUrl.isNotEmpty && ApiConfig.styleApiKey.isNotEmpty;
    if (useBase) {
      final uri = Uri.parse('${ApiConfig.baseUrl}/style-chat');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.styleApiKey}',
        },
        body: jsonEncode({'userId': uid, 'question': question}),
      );
      if (res.statusCode != 200) {
        throw Exception('Style chat API error: ${res.statusCode}');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return (json['answer'] as String?) ?? 'No answer generated.';
    }
    if (ApiConfig.openAiKey.isNotEmpty) {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final payload = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a fashion/style advisor. Provide concise, practical outfit and grooming advice.'
          },
          {'role': 'user', 'content': question}
        ],
        'temperature': 0.7,
      };
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openAiKey}',
        },
        body: jsonEncode(payload),
      );
      if (res.statusCode != 200) {
        throw Exception('OpenAI error: ${res.statusCode}');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = (json['choices'] as List?) ?? const [];
      final content = (choices.isNotEmpty
              ? (choices.first['message']?['content'] as String?)
              : null) ??
          'No answer generated.';
      return content;
    }
    return 'AI is not configured. Please set STYLE_API_BASE_URL/STYLE_API_KEY or OPENAI_API_KEY.';
  }
}
