import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF0D6EFD);
  static const background = Color(0xFFF4F6F9);
  static const card = Colors.white;
  static const organic = Color(0xFF198754);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Color(0xFF091C2B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Color(0xFF343A40)),
        bodySmall: TextStyle(color: Color(0xFF6C757D)),
      ),
    );
  }
}
