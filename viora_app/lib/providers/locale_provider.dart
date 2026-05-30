import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static LocaleProvider? _globalInstance;
  static LocaleProvider get global => _globalInstance ??= LocaleProvider();

  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  LocaleProvider() {
    _globalInstance = this;
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      // User has manually selected a language
      _locale = Locale(languageCode);
    } else {
      // Auto-detect device language
      // Default to Vietnamese if device language is not supported
      _locale = const Locale('vi');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  void clearLocale() {
    _locale = const Locale('vi');
    notifyListeners();
  }
}
