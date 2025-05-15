import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  // Keys for storing theme preferences
  static const String _themeKey = 'is_dark_mode';
  static const String _followSystemKey = 'follow_system';

  // Get the current theme from shared preferences
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Save the selected theme to shared preferences
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    // عند تعيين وضع السمة يدويًا، نلغي خيار اتباع النظام
    await prefs.setBool(_followSystemKey, false);
  }

  // Toggle the current theme
  Future<bool> toggleTheme() async {
    final isDark = await isDarkMode();
    await setDarkMode(!isDark);
    return !isDark;
  }

  // الحصول على حالة اتباع إعدادات النظام
  Future<bool> isFollowingSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followSystemKey) ?? false;
  }

  // تعيين حالة اتباع إعدادات النظام
  Future<void> setFollowSystem(bool follow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, follow);
  }
}
