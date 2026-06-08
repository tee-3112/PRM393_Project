import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFF66BB6A);
  static const Color incomeColor = Color(0xFF2E7D32);
  static const Color expenseColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFE53935);
  static const Color bgColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, brightness: Brightness.light, primary: primaryGreen, secondary: accent, surface: cardColor),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: const AppBarTheme(backgroundColor: primaryGreen, foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      cardTheme: CardThemeData(color: cardColor, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: primaryGreen, unselectedItemColor: textSecondary, type: BottomNavigationBarType.fixed, elevation: 8),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primaryGreen, foregroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
    );
  }
}