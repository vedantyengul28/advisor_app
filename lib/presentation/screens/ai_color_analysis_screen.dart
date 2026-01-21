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

class AIColorAnalysisScreen extends StatefulWidget {
  const AIColorAnalysisScreen({super.key});

  @override
  State<AIColorAnalysisScreen> createState() => _AIColorAnalysisScreenState();
}

class _AIColorAnalysisScreenState extends State<AIColorAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _loading = false;
  String? _result;

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
    final storage = StorageService();
    final url = await storage.uploadFeatureImage(uid, 'style_advisor', _image!);
    await AiService().analyzeStyle(uid, imageUrl: url);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc('style_advisor')
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    setState(() {
      _result = data?['analysis'] as String?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
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
                      const Text('Upload an image for color analysis', style: TextStyle(color: Colors.white)),
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
                if (_result != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Text(_result!, style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
