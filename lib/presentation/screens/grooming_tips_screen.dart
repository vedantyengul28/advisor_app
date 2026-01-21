import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ai_service.dart';

class GroomingTipsScreen extends StatefulWidget {
  const GroomingTipsScreen({super.key});

  @override
  State<GroomingTipsScreen> createState() => _GroomingTipsScreenState();
}

class _GroomingTipsScreenState extends State<GroomingTipsScreen> {
  bool _loading = false;
  List<String> _tips = const [];

  Future<void> _generate() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    await AiService().getGroomingTips(uid);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc('grooming')
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    final list = (data?['tips'] as List?)?.cast<String>() ?? const [];
    setState(() {
      _tips = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grooming Tips'),
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
                      Icon(Icons.spa, size: 60, color: Colors.white54),
                      SizedBox(height: 12),
                      Text('Get personalized grooming tips', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(text: 'Generate Tips', onPressed: _generate, isLoading: _loading),
                const SizedBox(height: 24),
                if (_tips.isNotEmpty)
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _tips
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
