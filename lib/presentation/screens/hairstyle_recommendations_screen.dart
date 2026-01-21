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
import '../widgets/platform_image_widget.dart';
import '../../data/services/platform_image_picker_service.dart';

class HairstyleRecommendationsScreen extends StatefulWidget {
  const HairstyleRecommendationsScreen({super.key});

  @override
  State<HairstyleRecommendationsScreen> createState() => _HairstyleRecommendationsScreenState();
}

class _HairstyleRecommendationsScreenState extends State<HairstyleRecommendationsScreen> {
  final PlatformImagePickerService _platformPicker = PlatformImagePickerService();
  XFile? _image;
  bool _loading = false;
  List<String> _suggestions = const [];

  Future<void> _pickImage() async {
    final img = await _platformPicker.pickGallery(context);
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
                              'Upload a clear headshot (frontal)',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                          : PlatformImage.xfile(_image!, fit: BoxFit.cover),
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
                          final img = await _platformPicker.pickCamera(context);
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
                    'Upload a headshot (clear frontal face) to get hairstyle suggestions.',
                    style: TextStyle(color: Colors.white),
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
