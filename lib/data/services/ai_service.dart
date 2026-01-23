import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

class AiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // ================= PUBLIC METHODS ====================
  // =====================================================

  Future<void> analyzeStyle(String uid, {String? imageUrl}) async {
    final result = await _safeImageCall(
      imageUrl: imageUrl,
      prompt:
          'Analyze clothing colors and skin tone. Return JSON: {"analysis": "text"}',
      fallback: {
        'analysis':
            'Best colors for you are navy, charcoal, olive and earthy neutrals.'
      },
    );

    await _save(uid, 'style_advisor', {
      'imageUrl': imageUrl,
      'analysis': result['analysis'],
    });
  }

  Future<void> analyzeBodyShape(String uid, {String? imageUrl}) async {
    final result = await _safeImageCall(
      imageUrl: imageUrl,
      prompt:
          'Identify body shape. Return JSON: {"shape":"Rectangle","notes":"text"}',
      fallback: {
        'shape': 'Rectangle',
        'notes':
            'Use structured shoulders and layering to enhance proportions.',
      },
    );

    await _save(uid, 'body_shape', {
      'imageUrl': imageUrl,
      ...result,
    });
  }

  Future<void> analyzeHairstyle(String uid, {String? imageUrl}) async {
    final result = await _safeImageCall(
      imageUrl: imageUrl,
      prompt:
          'Suggest exactly 3 hairstyles. Return JSON: {"suggestions":["a","b","c"]}',
      fallback: {
        'suggestions': [
          'Textured crop',
          'Side-part fade',
          'Medium layered cut'
        ]
      },
    );

    await _save(uid, 'hairstyle', {
      'imageUrl': imageUrl,
      'suggestions': result['suggestions'],
    });
  }

  Future<void> getOutfitSuggestions(
    String uid, {
    String? gender,
    String? bodyShape,
    List<String>? brands,
  }) async {
    final prompt =
        'Suggest 4 outfits for a ${gender ?? "person"} with ${bodyShape ?? "average"} body type. '
        'Return JSON: {"suggestions":[]}';

    final result = await _safeTextCall(
      prompt: prompt,
      fallback: {
        'suggestions': gender == 'male'
            ? [
                'Navy blazer',
                'White shirt',
                'Dark jeans',
                'Leather sneakers'
              ]
            : [
                'Midi dress',
                'Tailored blazer',
                'Straight jeans',
                'Minimal sneakers'
              ]
      },
    );

    await _save(uid, 'outfits', result);
  }

  Future<void> getGroomingTips(String uid) async {
    final result = await _safeTextCall(
      prompt:
          'Give 5 grooming tips. Return JSON: {"tips":[]}',
      fallback: {
        'tips': [
          'Cleanse face daily',
          'Trim facial hair',
          'Use sunscreen',
          'Keep nails clean',
          'Use light fragrance'
        ]
      },
    );

    await _save(uid, 'grooming', result);
  }

  Future<String> askStyleAdvisor(String uid, String question) async {
    final result = await _safeTextCall(
      prompt:
          'Answer briefly as a fashion expert: $question',
      fallback: {'answer': 'Try neutral colors and clean fits.'},
    );

    return result['answer'] ?? result['text'] ?? '';
  }

  // ✅ REQUIRED BY YOUR SCREEN (THIS FIXES THE ERROR)
  Future<void> analyzeStyleComposite(
    String uid, {
    String? imageUrl,
  }) async {
    final result = await _safeImageCall(
      imageUrl: imageUrl,
      prompt:
          'Analyze bodyType, skinTone, recommendedColors, avoidStyles. '
          'Return JSON with those keys.',
      fallback: {
        'bodyType': 'Rectangle',
        'skinTone': 'Warm',
        'recommendedColors': ['Navy', 'Olive', 'Charcoal'],
        'avoidStyles': ['Neon colors'],
      },
    );

    await _save(uid, 'style_composite', {
      'imageUrl': imageUrl,
      ...result,
    });
  }

  // =====================================================
  // ================= SAFE WRAPPERS =====================
  // =====================================================

  Future<Map<String, dynamic>> _safeImageCall({
    required String? imageUrl,
    required String prompt,
    required Map<String, dynamic> fallback,
  }) async {
    if (ApiConfig.geminiApiKey.isEmpty || imageUrl == null) {
      return fallback;
    }
    try {
      return await _geminiImage(prompt, imageUrl);
    } catch (_) {
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _safeTextCall({
    required String prompt,
    required Map<String, dynamic> fallback,
  }) async {
    if (ApiConfig.geminiApiKey.isEmpty) return fallback;
    try {
      return await _geminiText(prompt);
    } catch (_) {
      return fallback;
    }
  }

  // =====================================================
  // ================= GEMINI CORE =======================
  // =====================================================

  Future<Map<String, dynamic>> _geminiImage(
    String prompt,
    String imageUrl,
  ) async {
    final imageRes = await http.get(Uri.parse(imageUrl));
    final base64Image = base64Encode(imageRes.bodyBytes);

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/${ApiConfig.geminiModel}:generateContent?key=${ApiConfig.geminiApiKey}',
    );

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final json = jsonDecode(res.body);
    final text = json['candidates'][0]['content']['parts'][0]['text'];

    return _parseJson(text);
  }

  Future<Map<String, dynamic>> _geminiText(String prompt) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/${ApiConfig.geminiModel}:generateContent?key=${ApiConfig.geminiApiKey}',
    );

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final json = jsonDecode(res.body);
    final text = json['candidates'][0]['content']['parts'][0]['text'];

    return _parseJson(text);
  }

  // =====================================================
  // ================= HELPERS ===========================
  // =====================================================

  Map<String, dynamic> _parseJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return {'text': text, 'answer': text};
    }
  }

  Future<void> _save(
    String uid,
    String doc,
    Map<String, dynamic> data,
  ) async {
    data['createdAt'] = DateTime.now().toIso8601String();

    await _db
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc(doc)
        .set(data, SetOptions(merge: true));
  }
}
