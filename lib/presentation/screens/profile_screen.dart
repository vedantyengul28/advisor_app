import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/history_service.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final profile = auth.currentUserProfile;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering
                    Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
                    const Icon(Icons.settings, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 24),

                // User Info Card
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                             radius: 30,
                             backgroundColor: Colors.grey,
                             child: Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
                                if (uid == null) return;
                                await HistoryService().logEvent(uid, 'profile_action', {'action': 'edit_avatar'});
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit profile coming soon')));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            profile?.email ?? '',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Orders Button Link
                GlassContainer(
                   onTap: () {
                     Navigator.of(context).push(
                       MaterialPageRoute(builder: (_) => const OrdersScreen()),
                     );
                   },
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                   child: const Row(
                     children: [
                       Icon(Icons.inventory_2_outlined),
                       SizedBox(width: 16),
                       Expanded(child: Text('Orders')),
                       Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                     ],
                   ),
                ),
                const SizedBox(height: 24),

                // Profile Details
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('MY PROFILE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                       const Divider(color: Colors.white12, height: 24),
                       _buildInfoRow('Mobile Number', profile?.mobile ?? '-'),
                       _buildInfoRow('Gender', profile?.gender ?? '-'),
                       _buildInfoRow('Occupation', profile?.occupation ?? '-'),
                       _buildInfoRow('Desired Style', profile?.stylePreference ?? '-'),
                       _buildInfoRow('Brands', profile?.brands ?? '-'),
                       _buildInfoRow('Address', profile?.address ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings Links
                _buildMenuButton(context, 'Looksmart Tutorial', Icons.play_circle_outline),
                _buildMenuButton(context, 'About', Icons.info_outline),
                
                const SizedBox(height: 10),
                GlassContainer(
                   onTap: () async {
                     await Provider.of<AuthService>(context, listen: false).signOut();
                     Navigator.of(context).pushReplacement(
                       MaterialPageRoute(builder: (_) => const LoginScreen()),
                     );
                   },
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                   child: const Row(
                     children: [
                       Icon(Icons.logout),
                       SizedBox(width: 16),
                       Expanded(child: Text('LogOut')),
                       Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                     ],
                   ),
                ),
                
                const SizedBox(height: 24),
                const Text('Version 0.1.1', style: TextStyle(color: Colors.white24)),
                const SizedBox(height: 80), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.white54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
         onTap: () async {
           final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
           if (uid == null) return;
           await HistoryService().logEvent(uid, 'menu_click', {'title': title});
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title opened')));
         },
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
         child: Row(
           children: [
             Icon(icon),
             const SizedBox(width: 16),
             Expanded(child: Text(title)),
             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
           ],
         ),
      ),
    );
  }
}
