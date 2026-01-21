import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/brands_service.dart';
import '../../data/services/ai_service.dart';

class OutfitSuggestionsScreen extends StatefulWidget {
  const OutfitSuggestionsScreen({super.key});

  @override
  State<OutfitSuggestionsScreen> createState() => _OutfitSuggestionsScreenState();
}

class _OutfitSuggestionsScreenState extends State<OutfitSuggestionsScreen> {
  bool _loading = false;
  List<String> _suggestions = const [];

  Future<void> _generate() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final brands = await BrandsService().getUserBrandIds(uid);
    await AiService().getOutfitSuggestions(
      uid,
      gender: auth.currentUserProfile?.gender,
      brands: brands,
    );
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc('outfits')
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    final list = (data?['suggestions'] as List?)?.cast<String>() ?? const [];
    setState(() {
      _suggestions = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Suggestions'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: const [
                      Icon(Icons.checkroom, size: 60, color: Colors.white54),
                      SizedBox(height: 12),
                      Text('Generate outfit suggestions', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(text: 'Get Suggestions', onPressed: _generate, isLoading: _loading),
                const SizedBox(height: 24),
                if (_suggestions.isNotEmpty)
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _suggestions
                          .map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text('• $s', style: const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
