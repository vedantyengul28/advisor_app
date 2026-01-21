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

class AIColorAnalysisScreen extends StatefulWidget {
  const AIColorAnalysisScreen({super.key});

  @override
  State<AIColorAnalysisScreen> createState() => _AIColorAnalysisScreenState();
}

class _AIColorAnalysisScreenState extends State<AIColorAnalysisScreen> {
  final PlatformImagePickerService _platformPicker = PlatformImagePickerService();
  XFile? _image;
  bool _loading = false;
  String? _result;

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
                              'No image selected',
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
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.analytics, color: Colors.white),
                        label: const Text('Analyze'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _loading ? null : _analyze,
                      ),
                    ),
                  ],
                ),
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
