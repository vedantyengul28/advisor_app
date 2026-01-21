import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'onboarding_about_you_screen.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'package:flutter/foundation.dart';

class StyleJourneyStartScreen extends StatelessWidget {
  const StyleJourneyStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    height: 96,
                    width: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/logo.png')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('StyleAI', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Discover Your Best Look with AI',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Get personalized style recommendations, color analysis, and outfit suggestions powered by artificial intelligence.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _StartChip(icon: Icons.palette, label: 'AI Analysis'),
                      _StartChip(icon: Icons.tips_and_updates, label: 'Style Tips'),
                      _StartChip(icon: Icons.timeline, label: 'Progress'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    text: 'Start Your Style Journey',
                    onPressed: () async {
                      final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
                      if (uid != null) {
                        await HistoryService().logNavigation(uid, 'onboarding_start');
                      }
                      if (kIsWeb) {} // no-op
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const OnboardingAboutYouScreen()),
                        );
                      }
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
}

class _StartChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StartChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

