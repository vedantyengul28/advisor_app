import 'package:flutter/material.dart';
import '../../presentation/screens/ai_color_analysis_screen.dart';
import '../../presentation/screens/body_shape_analysis_screen.dart';
import '../../presentation/screens/hairstyle_recommendations_screen.dart';
import '../../presentation/screens/outfit_suggestions_screen.dart';
import '../../presentation/screens/grooming_tips_screen.dart';

class StyleFeaturesService {
  static Future<void> openAIColorAnalysis(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AIColorAnalysisScreen()));
  }

  static Future<void> openBodyShapeAnalysis(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyShapeAnalysisScreen()));
  }

  static Future<void> openHairstyleRecommendations(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HairstyleRecommendationsScreen()));
  }

  static Future<void> openOutfitSuggestions(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const OutfitSuggestionsScreen()));
  }

  static Future<void> openGroomingTips(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GroomingTipsScreen()));
  }
}
