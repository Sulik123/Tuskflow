import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета (как на сайте)
  static const Color primary = Color(0xFF6B46C1);      // Фиолетовый
  static const Color accent = Color(0xFF10B981);       // Зеленый (выполнено)
  static const Color background = Color(0xFFF9FAFB);   // Светло-серый фон
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFF3F4F6);
  static const Color text = Color(0xFF1F2937);         // Темно-серый
  static const Color textLight = Color(0xFF6B7280);    // Серый
  static const Color textTertiary = Color(0xFF9CA3AF); // Еще более серый
  static const Color border = Color(0xFFE5E7EB);       // Светло-серый для границ
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  
  // Приоритеты
  static const Color priorityHigh = Color(0xFFDC2626);   // Красный
  static const Color priorityMedium = Color(0xFFF59E0B); // Оранжевый
  static const Color priorityLow = accent;               // Зеленый
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}