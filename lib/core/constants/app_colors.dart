import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF1E40AF);    // Deep Zeal Blue
  static const Color lightOnPrimary = Colors.white;
  static const Color lightSecondary = Color(0xFF0F766E);  // Vibrant Teal
  static const Color lightOnSecondary = Colors.white;
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean Light Gray/Slate
  static const Color lightSurface = Colors.white;
  static const Color lightOnBackground = Color(0xFF0F172A); // Slate 900
  static const Color lightOnSurface = Color(0xFF1E293B);    // Slate 800
  static const Color lightOutline = Color(0xFFCBD5E1);      // Slate 300

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF3B82F6);     // Bright Royal Blue
  static const Color darkOnPrimary = Color(0xFF0F172A);
  static const Color darkSecondary = Color(0xFF14B8A6);   // Bright Teal
  static const Color darkOnSecondary = Color(0xFF0F172A);
  static const Color darkBackground = Color(0xFF090D16);  // Deep Rich Black
  static const Color darkSurface = Color(0xFF151C2C);     // Deep Slate Card
  static const Color darkOnBackground = Color(0xFFF1F5F9); // Slate 100
  static const Color darkOnSurface = Color(0xFFE2E8F0);    // Slate 200
  static const Color darkOutline = Color(0xFF334155);      // Slate 700

  // Accent Colors
  static const Color accentGold = Color(0xFFF59E0B);      // Zeal Gold
  static const Color errorRed = Color(0xFFEF4444);        // Modern red
  static const Color successGreen = Color(0xFF10B981);    // Emerald Green

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF151C2C), Color(0xFF090D16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
