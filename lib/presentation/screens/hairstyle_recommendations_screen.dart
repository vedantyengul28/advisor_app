import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/ai_service.dart';

class HairstyleRecommendationsScreen extends StatefulWidget {
  const HairstyleRecommendationsScreen({super.key});

  @override
  State<HairstyleRecommendationsScreen> createState() => _HairstyleRecommendationsScreenState();
}

class _HairstyleRecommendationsScreenState extends State<HairstyleRecommendationsScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _loading = false;
  List<String> _suggestions = const [];

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _image = img);
    }
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final url = await StorageService().uploadFeatureImage(uid, 'hairstyle', _image!);
    await AiService().analyzeHairstyle(uid, imageUrl: url);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc('hairstyle')
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
        title: const Text('Hairstyle Recommendations'),
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
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.white54),
                      const SizedBox(height: 12),
                      const Text('Upload headshot image', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      OutlinedButton(onPressed: _pickImage, child: const Text('Choose Image')),
                      if (_image != null) ...[
                        const SizedBox(height: 16),
                        Image.file(File(_image!.path), height: 160, fit: BoxFit.cover),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(text: 'Analyze', onPressed: _analyze, isLoading: _loading),
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
