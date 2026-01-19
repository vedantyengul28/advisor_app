import 'package:flutter/material.dart';

class AppColors {
  // Primary Background Gradient Colors
  static const Color backgroundStart = Color(0xFF0B1221); // Deep dark blue
  static const Color backgroundEnd = Color(0xFF132238);   // Slightly lighter blue/teal

  // Accent Colors
  static const Color primaryAccent = Color(0xFFE91E63); // Pink/Magenta
  static const Color primaryAccentGlow = Color(0xFFFF4081); 
  
  // UI Colors
  static const Color cardColor = Color(0xFF1E2A3C); // Fallback for glass
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color iconColor = Colors.white;
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color pending = Color(0xFFFF9800);
  static const Color shipping = Color(0xFF2196F3);
  
  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static final Color glassBorder = Colors.white.withOpacity(0.1);
}
