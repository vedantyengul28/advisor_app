import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

class AiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> analyzeStyle(String uid, {String? imageUrl}) async {
    if (ApiConfig.openAiKey.isNotEmpty && imageUrl != null) {
      try {
        final analysis = await _analyzeImageWithOpenAI(
          system: 'You are a color analyst and stylist. Analyze the person image and return concise palette guidance.',
          imageUrl: imageUrl,
          jsonSchemaHint:
              'Return JSON with "analysis" string. Keep advice practical and short. No markdown.',
        );
        final data = {
          'imageUrl': imageUrl,
          'analysis': analysis['analysis'] ?? 'Unable to analyze colors.',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _db.collection('users').doc(uid).collection('ai_results').doc('style_advisor').set(
              data,
              SetOptions(merge: true),
            );
        return;
      } catch (_) {
        // fall through to mock
      }
    }
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
    if (ApiConfig.openAiKey.isNotEmpty && imageUrl != null) {
      try {
        final result = await _analyzeImageWithOpenAI(
          system:
              'You are a fashion body-shape analyst. Inspect the person image and classify as one of {Hourglass, Rectangle, Pear, Inverted Triangle, Oval}. Provide one-paragraph styling notes.',
          imageUrl: imageUrl,
          jsonSchemaHint:
              'Return JSON with keys: "shape" (string) and "notes" (string). Keep notes concise. No markdown.',
        );
        final data = {
          'imageUrl': imageUrl,
          'shape': result['shape'] ?? 'Rectangle',
          'notes': result['notes'] ??
              'Balance proportions with structured shoulders and defined waist. Layering helps add dimension.',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _db.collection('users').doc(uid).collection('ai_results').doc('body_shape').set(
              data,
              SetOptions(merge: true),
            );
        return;
      } catch (_) {
        // fall through to mock
      }
    }
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
    if (ApiConfig.openAiKey.isNotEmpty && imageUrl != null) {
      try {
        final result = await _analyzeImageWithOpenAI(
          system:
              'You are a hairstyle expert. Review the headshot and recommend 3 hairstyles that fit hair type and face shape.',
          imageUrl: imageUrl,
          jsonSchemaHint:
              'Return JSON with "suggestions": array of 3 short strings. No markdown.',
        );
        final suggestions = (result['suggestions'] as List?)?.cast<String>() ??
            [
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
        return;
      } catch (_) {
        // fall through to mock
      }
    }
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
      try {
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
      } catch (_) {
        return 'Unable to get AI reply. Please try again later.';
      }
    }
    if (ApiConfig.openAiKey.isNotEmpty) {
      try {
        final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
        final payload = {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional fashion stylist AI. Give concise, practical fashion advice.'
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
      } catch (_) {
        return 'Unable to get AI reply. Please try again later.';
      }
    }
    return 'AI is not configured. Please set STYLE_API_BASE_URL/STYLE_API_KEY or OPENAI_API_KEY.';
  }

  Future<Map<String, dynamic>> _analyzeImageWithOpenAI({
    required String system,
    required String imageUrl,
    required String jsonSchemaHint,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final messages = [
      {
        'role': 'system',
        'content': system,
      },
      {
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 'Analyze this image and respond as JSON only. $jsonSchemaHint'},
          {
            'type': 'input_image',
            'image_url': {'url': imageUrl},
          },
        ],
      },
    ];
    final payload = {
      'model': 'gpt-4o-mini',
      'messages': messages,
      'temperature': 0.3,
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
      throw Exception('OpenAI error: ${res.statusCode} ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final content = (json['choices'] as List?)?.isNotEmpty == true
        ? (json['choices'][0]['message']['content'] as String? ?? '{}')
        : '{}';
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {'analysis': content};
    }
  }

  Future<Map<String, dynamic>> analyzeStyleComposite(String uid, {String? imageUrl}) async {
    Map<String, dynamic> result = {
      'bodyType': 'Rectangle',
      'skinTone': 'Warm Olive',
      'recommendedColors': ['Navy', 'Olive', 'Charcoal', 'Cream'],
      'avoidStyles': ['Neon', 'Overly saturated hues'],
      'createdAt': DateTime.now().toIso8601String(),
    };
    if (ApiConfig.openAiKey.isNotEmpty && imageUrl != null) {
      try {
        final openAi = await _analyzeImageWithOpenAI(
          system:
              'You are a fashion stylist. Analyze the person image and return JSON with keys: bodyType, skinTone, recommendedColors (array), avoidStyles (array).',
          imageUrl: imageUrl,
          jsonSchemaHint:
              'Return JSON with keys: "bodyType" (string), "skinTone" (string), "recommendedColors" (array of strings), "avoidStyles" (array of strings). No markdown.',
        );
        result = {
          'bodyType': openAi['bodyType'] ?? result['bodyType'],
          'skinTone': openAi['skinTone'] ?? result['skinTone'],
          'recommendedColors': (openAi['recommendedColors'] as List?)?.cast<String>() ?? result['recommendedColors'],
          'avoidStyles': (openAi['avoidStyles'] as List?)?.cast<String>() ?? result['avoidStyles'],
          'createdAt': DateTime.now().toIso8601String(),
        };
      } catch (_) {}
    }
    if (imageUrl != null) {
      result['imageUrl'] = imageUrl;
    }
    await _db.collection('users').doc(uid).collection('ai_results').doc('style_composite').set(
          result,
          SetOptions(merge: true),
        );
    return result;
  }
}
