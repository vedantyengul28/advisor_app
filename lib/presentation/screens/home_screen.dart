import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/feature_card.dart';
import '../widgets/custom_text_field.dart';
import 'try_on_screen.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'chat_screen.dart';
import 'ai_tools_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final history = HistoryService();
    final searchController = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LookSmart',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          'Find your unique style',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), // Placeholder
                      radius: 24,
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                CustomTextField(
                  controller: searchController,
                  hintText: 'Search brands, outfits...',
                  prefixIcon: Icons.search,
                ),
                const SizedBox(height: 24),

                // Try-On Promo
                FeatureCard(
                  title: 'Virtual Try-On',
                  subtitle: 'Upload your photo and try on clothes instantly.',
                  buttonText: 'Try It On',
                  buttonColor: AppColors.shipping,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TryOnScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // AI Tools Grid Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Tools',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
                        if (uid == null) return;
                        await HistoryService().logNavigation(uid, 'ai_tools_see_all');
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIToolsScreen()));
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mini Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                     _buildMiniToolCard(context, 'Outfit ID', Icons.camera_alt, Colors.purple),
                     _buildMiniToolCard(context, 'Style Chat', Icons.chat_bubble, Colors.blue),
                     _buildMiniToolCard(context, 'Wardrobe', Icons.door_sliding, Colors.orange),
                     _buildMiniToolCard(context, 'Trends', Icons.trending_up, Colors.pink),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniToolCard(BuildContext context, String title, IconData icon, Color color) {
    return GlassContainer(
      onTap: () async {
        final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
        if (uid == null) return;
        await HistoryService().logNavigation(uid, title.toLowerCase().replaceAll(' ', '_'));
        if (title == 'Style Chat') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        } else if (title == 'Outfit ID') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TryOnScreen()));
        } else if (title == 'Wardrobe') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
        } else if (title == 'Trends') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIToolsScreen()));
        }
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
