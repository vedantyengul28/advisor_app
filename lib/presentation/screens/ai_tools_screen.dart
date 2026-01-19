import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/ai_tool_card.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final history = HistoryService();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Text(
                'LookSmart',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI-Powered Style Assistant',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              
              AIToolCard(
                title: 'AI Analysis',
                subtitle: 'Discover your perfect color palette.',
                icon: Icons.palette,
                onTap: () async {
                  final uid = auth.currentUser?.uid;
                  if (uid == null) return;
                  await history.logToolUse(uid, 'ai_analysis');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Analysis started')),
                  );
                },
              ),
              AIToolCard(
                title: 'Body Shape Analysis',
                subtitle: 'Understand your unique body type.',
                icon: Icons.accessibility_new,
                onTap: () async {
                  final uid = auth.currentUser?.uid;
                  if (uid == null) return;
                  await history.logToolUse(uid, 'body_shape_analysis');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Body Shape Analysis started')),
                  );
                },
              ),
              AIToolCard(
                title: 'Hairstyle Recommendations',
                subtitle: 'Find the styles that suit you best.',
                icon: Icons.face,
                onTap: () async {
                  final uid = auth.currentUser?.uid;
                  if (uid == null) return;
                  await history.logToolUse(uid, 'hairstyle_recommendations');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hairstyle Recommendations started')),
                  );
                },
              ),
              AIToolCard(
                title: 'Outfit Suggestions',
                subtitle: 'Get personalized fashion insights',
                icon: Icons.checkroom, // Hanger
                onTap: () async {
                  final uid = auth.currentUser?.uid;
                  if (uid == null) return;
                  await history.logToolUse(uid, 'outfit_suggestions');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Outfit Suggestions started')),
                  );
                },
              ),
              AIToolCard(
                title: 'Grooming Tips',
                subtitle: 'Style and self-improvement guidance.',
                icon: Icons.spa, // Lotus
                onTap: () async {
                  final uid = auth.currentUser?.uid;
                  if (uid == null) return;
                  await history.logToolUse(uid, 'grooming_tips');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grooming Tips opened')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
