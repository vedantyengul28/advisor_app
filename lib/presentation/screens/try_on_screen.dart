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

  void _processTryOn() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isResultReady = true;
        });
      }
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
                  await HistoryService().logEvent(uid, 'tryon', {'action': 'choose_image'});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented')));
                },
                child: const Text('Choose Image'),
              ),
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
                  Container(height: 200, color: Colors.grey, child: const Center(child: Text('Original'))),
                ],
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: Column(
                children: [
                  Container(height: 200, color: AppColors.primaryAccent, child: const Center(child: Text('Simulated'))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Save Look',
          onPressed: _saveLook,
        ),
        const SizedBox(height: 16),
         TextButton(
          onPressed: () => setState(() => _isResultReady = false),
          child: const Text('Try Another'),
        ),
      ],
    );
  }
}
