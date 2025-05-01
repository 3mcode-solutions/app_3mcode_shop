import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  // Singleton instance
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  // Key for storing language preference
  static const String _languageKey = 'language_code';

  // Default language
  static const Locale defaultLocale = Locale('en');

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];

  // Get the current locale from shared preferences
  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageKey);
    
    if (languageCode == null) {
      return defaultLocale;
    }
    
    return Locale(languageCode);
  }

  // Save the selected locale to shared preferences
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  // Check if the current locale is RTL
  static bool isRtl(Locale locale) {
    return locale.languageCode == 'ar';
  }

  // Get the display name of the language
  static String getDisplayLanguage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  // Get the flag icon for the language
  static String getFlagIcon(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }
}
