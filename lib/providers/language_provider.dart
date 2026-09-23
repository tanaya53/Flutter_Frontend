import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('mr'); // Default to Marathi मराठी for Ashram School platform

  Locale get locale => _locale;
  bool get isMarathi => _locale.languageCode == 'mr';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language_code') ?? 'mr';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'mr') {
      await setLanguage('en');
    } else {
      await setLanguage('mr');
    }
  }

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', code);
    notifyListeners();
  }
}
