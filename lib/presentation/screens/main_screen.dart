import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'home_screen.dart';
import 'ai_tools_screen.dart';
import 'chat_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIToolsScreen(),
    const OrdersScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundEnd,
            title: const Text('Exit LookSmart?', style: TextStyle(color: Colors.white)),
            content: const Text('Do you really want to exit?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: AppColors.primaryAccent)),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundStart,
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 0), // Hide labels if needed or style them
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: AppColors.backgroundStart,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white38,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  activeIcon: Icon(Icons.home_filled, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.extension), // Puzzle piece
                  activeIcon: Icon(Icons.extension, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                  label: 'Tools',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.card_giftcard),
                  activeIcon: Icon(Icons.card_giftcard, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                  label: 'Rewards',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  activeIcon: Icon(Icons.shopping_bag, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  activeIcon: Icon(Icons.person, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
