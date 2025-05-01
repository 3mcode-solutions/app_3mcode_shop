import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  // Key for storing theme preference
  static const String _themeKey = 'is_dark_mode';

  // Get the current theme from shared preferences
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Save the selected theme to shared preferences
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Toggle the current theme
  Future<bool> toggleTheme() async {
    final isDark = await isDarkMode();
    await setDarkMode(!isDark);
    return !isDark;
  }
}
