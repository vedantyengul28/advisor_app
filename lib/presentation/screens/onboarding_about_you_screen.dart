import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'onboarding_brands_screen.dart';

class OnboardingAboutYouScreen extends StatefulWidget {
  const OnboardingAboutYouScreen({super.key});
  @override
  State<OnboardingAboutYouScreen> createState() => _OnboardingAboutYouScreenState();
}

class _OnboardingAboutYouScreenState extends State<OnboardingAboutYouScreen> {
  String _department = 'Male';
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('About You'),
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
                  LinearProgressIndicator(
                    value: 0.2,
                    minHeight: 4,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Which department do you prefer to shop in?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _optionTile(context, 'Female')),
                      const SizedBox(width: 12),
                      Expanded(child: _optionTile(context, 'Male')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Continue',
                    onPressed: () async {
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      await auth.updateProfile(gender: _department);
                      await HistoryService().logEvent(uid, 'onboarding', {'step': 'about_you', 'department': _department});
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingBrandsScreen()),
                      );
                    },
                    isLoading: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, String label) {
    final selected = _department == label;
    return GestureDetector(
      onTap: () => setState(() => _department = label),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.green : AppColors.glassBorder, width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

