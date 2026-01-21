import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/try_on_service.dart';
import '../../data/models/try_on_model.dart';
import '../../data/services/history_service.dart';
import 'package:image_picker/image_picker.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  bool _isProcessing = false;
  bool _isResultReady = false;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyTypeController = TextEditingController();
  final TryOnService _tryOnService = TryOnService();
  final ImagePicker _picker = ImagePicker();
  XFile? _userImage;
  XFile? _clothingImage;
  String? _error;

  void _processTryOn() {
    if (_userImage == null || _clothingImage == null) {
      setState(() => _error = 'Please select your photo and a clothing image.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both user photo and clothing image')),
      );
      return;
    }
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isResultReady = true;
      });
    });
  }
  
  Future<void> _saveLook() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final record = TryOnRecord(
      userId: uid,
      heightCm: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
      weightKg: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
      bodyType: _bodyTypeController.text.isNotEmpty ? _bodyTypeController.text : null,
      createdAt: DateTime.now(),
    );
    await _tryOnService.saveRecord(record);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your looks')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Try-On'),
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
            child: _isResultReady ? _buildResultView() : _buildInputForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.white54),
              const SizedBox(height: 16),
              const Text('Upload Front Body Photo', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () async {
                  final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
                  if (uid == null) return;
                  await HistoryService().logEvent(uid, 'tryon', {'action': 'choose_user_image'});
                  final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (img != null) {
                    setState(() => _userImage = img);
                  }
                },
                child: const Text('Choose Image'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
                  if (uid == null) return;
                  await HistoryService().logEvent(uid, 'tryon', {'action': 'choose_clothing_image'});
                  final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (img != null) {
                    setState(() => _clothingImage = img);
                  }
                },
                child: const Text('Choose Clothing'),
              ),
              const SizedBox(height: 16),
              if (_userImage != null)
                Column(
                  children: [
                    const Text('Selected Photo', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Image.file(File(_userImage!.path), height: 160, fit: BoxFit.cover),
                  ],
                ),
              const SizedBox(height: 12),
              if (_clothingImage != null)
                Column(
                  children: [
                    const Text('Selected Clothing', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Image.file(File(_clothingImage!.path), height: 120, fit: BoxFit.contain),
                  ],
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(hintText: 'Height (cm)', controller: _heightController),
        const SizedBox(height: 16),
        CustomTextField(hintText: 'Weight (kg)', controller: _weightController),
        const SizedBox(height: 16),
        CustomTextField(hintText: 'Body Type (e.g. Hourglass)', controller: _bodyTypeController),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Generate Try-On',
          onPressed: _processTryOn,
          isLoading: _isProcessing,
          colors: const [AppColors.shipping, Color(0xFF42A5F5)],
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        const Text('AI Try-On Result', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _userImage == null
                        ? const Center(child: Text('Original'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_userImage!.path), fit: BoxFit.cover),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _userImage == null
                        ? const Center(child: Text('Simulated'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final w = constraints.maxWidth;
                                final h = constraints.maxHeight;
                                // Mock torso region: center area covering ~50% width, ~40% height starting at 30% from top
                                final torsoWidth = w * 0.5;
                                final torsoHeight = h * 0.4;
                                final torsoLeft = (w - torsoWidth) / 2;
                                final torsoTop = h * 0.30;
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(_userImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (_clothingImage != null)
                                      Positioned(
                                        left: torsoLeft,
                                        top: torsoTop,
                                        width: torsoWidth,
                                        height: torsoHeight,
                                        child: Image.file(
                                          File(_clothingImage!.path),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Save Look',
          onPressed: _saveLook,
          colors: const [AppColors.shipping, Color(0xFF42A5F5)],
        ),
        const SizedBox(height: 16),
         TextButton(
          onPressed: () {
            setState(() {
              _isResultReady = false;
              _userImage = null;
              _clothingImage = null;
              _error = null;
            });
          },
          child: const Text('Retake'),
        ),
      ],
    );
  }
}
