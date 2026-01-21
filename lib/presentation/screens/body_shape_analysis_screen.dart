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

class BodyShapeAnalysisScreen extends StatefulWidget {
  const BodyShapeAnalysisScreen({super.key});

  @override
  State<BodyShapeAnalysisScreen> createState() => _BodyShapeAnalysisScreenState();
}

class _BodyShapeAnalysisScreenState extends State<BodyShapeAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _loading = false;
  String? _shape;
  String? _notes;

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
    final url = await StorageService().uploadFeatureImage(uid, 'body_shape', _image!);
    await AiService().analyzeBodyShape(uid, imageUrl: url);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_results')
        .doc('body_shape')
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    setState(() {
      _shape = data?['shape'] as String?;
      _notes = data?['notes'] as String?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Shape Analysis'),
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
                      const Text('Upload full-body image', style: TextStyle(color: Colors.white)),
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
                if (_shape != null || _notes != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_shape != null)
                          Text('Shape: $_shape', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        if (_notes != null)
                          Text(_notes!, style: const TextStyle(color: Colors.white)),
                      ],
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
