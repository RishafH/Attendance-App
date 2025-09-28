import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  // Supported locales
  final List<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('si'), // Sinhala
    Locale('ta'), // Tamil
  ];

  // Language names for display
  final Map<String, String> languageNames = {
    'en': 'English',
    'si': 'සිංහල',
    'ta': 'தமிழ்',
  };

  LocalizationProvider() {
    _loadSavedLocale();
  }

  // Load saved locale from preferences
  void _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString('language_code');
      
      if (savedLanguageCode != null) {
        final savedLocale = Locale(savedLanguageCode);
        if (supportedLocales.contains(savedLocale)) {
          _locale = savedLocale;
          notifyListeners();
        }
      }
    } catch (e) {
      // If loading fails, keep default locale
      debugPrint('Failed to load saved locale: $e');
    }
  }

  // Change locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }

    _locale = locale;
    notifyListeners();

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }

  // Get current language name
  String getCurrentLanguageName() {
    return languageNames[_locale.languageCode] ?? 'English';
  }

  // Check if current locale is RTL (not applicable for our languages, but good to have)
  bool get isRTL {
    return _locale.languageCode == 'ar' || _locale.languageCode == 'he';
  }
}