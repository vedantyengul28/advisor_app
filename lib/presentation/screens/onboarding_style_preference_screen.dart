import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'main_screen.dart';

class OnboardingStylePreferenceScreen extends StatefulWidget {
  const OnboardingStylePreferenceScreen({super.key});
  @override
  State<OnboardingStylePreferenceScreen> createState() => _OnboardingStylePreferenceScreenState();
}

class _OnboardingStylePreferenceScreenState extends State<OnboardingStylePreferenceScreen> {
  final List<String> _styles = ['Casual', 'Formal', 'Streetwear', 'Luxury', 'Minimalist'];
  String? _selected;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: 0.8,
                    minHeight: 4,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 24),
                  Text('What is your desired style?', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _styles
                        .map((s) => ChoiceChip(
                              label: Text(s),
                              selected: _selected == s,
                              onSelected: (_) => setState(() => _selected = s),
                              labelStyle: const TextStyle(color: Colors.white),
                              selectedColor: Colors.green.withOpacity(0.3),
                              backgroundColor: Colors.white.withOpacity(0.06),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Finish',
                    onPressed: () async {
                      if (_selected == null) return;
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      await auth.updateProfile(stylePreference: _selected);
                      await HistoryService().logEvent(uid, 'onboarding', {'step': 'style', 'value': _selected});
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
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
}
