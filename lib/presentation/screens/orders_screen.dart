import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/glass_container.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/orders_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final ordersService = OrdersService();
    Future<void> _refresh() async {
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      final stats = await ordersService.getOrderStats(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Orders: ${stats['total']}, Delivered: ${stats['delivered']}')),
      );
    }
    Future<void> _search() async {
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      final orders = await ordersService.getOrdersByUser(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${orders.length} orders')),
      );
    }
    return DefaultTabController(
      length: 4,
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Orders',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Track your purchases',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                           _buildIconButton(Icons.search, onTap: _search),
                           const SizedBox(width: 8),
                           _buildIconButton(Icons.refresh, onTap: _refresh),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  const Row(
                    children: [
                      StatCard(label: 'Total Orders', value: '0', icon: Icons.shopping_bag_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      StatCard(label: 'Delivered', value: '0', icon: Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      StatCard(label: 'Total Spent', value: '₹0', icon: Icons.currency_rupee, color: Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  TabBar(
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.pending,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.pending,
                    dividerColor: Colors.transparent,
                    tabs: const [
                       Tab(text: 'All'),
                       Tab(text: 'Pending'),
                       Tab(text: 'Confirmed'),
                       Tab(text: 'Shipped'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Empty State
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.white54),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "You haven't placed any orders yet!",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Start shopping to see your orders here",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GlassContainer(
      padding: const EdgeInsets.all(10),
      borderRadius: 12,
      onTap: onTap,
      child: Icon(icon, color: Colors.orange, size: 20),
    );
  }
}
