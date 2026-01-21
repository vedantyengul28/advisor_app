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
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _image == null
                        ? const Center(
                            child: Text(
                              'Upload a full-body photo (front)',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                        : Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                          if (img != null) setState(() => _image = img);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Upload a full-body photo (front) for best results.',
                    style: TextStyle(color: Colors.white),
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
