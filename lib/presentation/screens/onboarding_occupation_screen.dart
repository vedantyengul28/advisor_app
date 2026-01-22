import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'onboarding_style_preference_screen.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingOccupationScreen extends StatefulWidget {
  const OnboardingOccupationScreen({super.key});
  @override
  State<OnboardingOccupationScreen> createState() => _OnboardingOccupationScreenState();
}

class _OnboardingOccupationScreenState extends State<OnboardingOccupationScreen> {
  final List<String> _options = [
    'Student',
    'Marketing Lead',
    'Teacher',
    'Software Engineer',
    'Sales Manager',
    'Accountant',
    'Designer',
    'Business Owner',
    'Lawyer',
  ];
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
                    value: 0.6,
                    minHeight: 4,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 24),
                  Text('What do you do for work?', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _options
                        .map((o) => ChoiceChip(
                              label: Text(o),
                              selected: _selected == o,
                              onSelected: (_) => setState(() => _selected = o),
                              labelStyle: const TextStyle(color: Colors.white),
                              selectedColor: Colors.green.withOpacity(0.3),
                              backgroundColor: Colors.white.withOpacity(0.06),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Continue',
                    onPressed: () async {
                      if (_selected == null) return;
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      await auth.updateProfile(occupation: _selected);
                      await HistoryService().logEvent(uid, 'onboarding', {'step': 'occupation', 'value': _selected});
                      await OnboardingService().markStep(uid, 'occupation', {'value': _selected});
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingStylePreferenceScreen()),
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
