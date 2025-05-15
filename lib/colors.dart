import 'package:flutter/material.dart';

class AppColors {
  // ألوان الوضع الفاتح
  static const Color primary = Color(0xff0CA201);
  static const Color primaryLight = Color(0xff4CD964);
  static const Color primaryDark = Color(0xff097801);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);

  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEEEEEE);

  // ألوان الوضع الداكن
  static const Color primaryDarkMode = Color(0xff4CD964);
  static const Color primaryLightDarkMode = Color(0xff81C784);
  static const Color primaryDarkDarkMode = Color(0xff0CA201);

  static const Color backgroundDarkMode = Color(0xFF121212);
  static const Color surfaceDarkMode = Color(0xFF1E1E1E);
  static const Color cardDarkMode = Color(0xFF2C2C2C);

  static const Color textDarkMode = Color(0xFFFFFFFF);
  static const Color textSecondaryDarkMode = Color(0xFFBBBBBB);
  static const Color dividerDarkMode = Color(0xFF333333);

  // دالة للحصول على اللون المناسب حسب الوضع
  static Color getColor(Color lightColor, Color darkColor, bool isDark) {
    return isDark ? darkColor : lightColor;
  }
}
