import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/brands_service.dart';
import '../../data/models/brand_model.dart';
import '../../data/services/history_service.dart';
import 'onboarding_occupation_screen.dart';

class OnboardingBrandsScreen extends StatefulWidget {
  const OnboardingBrandsScreen({super.key});
  @override
  State<OnboardingBrandsScreen> createState() => _OnboardingBrandsScreenState();
}

class _OnboardingBrandsScreenState extends State<OnboardingBrandsScreen> {
  bool _loading = true;
  List<Brand> _catalog = const [];
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await BrandsService().getCatalog();
    if (!mounted) return;
    setState(() {
      _catalog = list;
      _loading = false;
    });
  }

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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 4,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose 3 or more brands',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      Text('Selected: ${_selected.length}/3', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            itemBuilder: (_, i) {
                              final b = _catalog[i];
                              final sel = _selected.contains(b.id);
                              return GlassContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selected.remove(b.id);
                                    } else {
                                      _selected.add(b.id);
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(b.name, style: const TextStyle(color: Colors.white)),
                                    Icon(sel ? Icons.remove_circle : Icons.add_circle, color: sel ? Colors.redAccent : Colors.greenAccent),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemCount: _catalog.length,
                          ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: 'Continue',
                    onPressed: () async {
                      if (_selected.length < 3) return;
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      await BrandsService().setUserBrands(uid, _selected.toList());
                      await HistoryService().logEvent(uid, 'onboarding', {'step': 'brands', 'count': _selected.length});
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingOccupationScreen()),
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
