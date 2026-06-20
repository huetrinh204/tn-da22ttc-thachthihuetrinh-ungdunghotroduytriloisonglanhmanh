import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
      _locale = Locale(languageCode);
    } else {
      _locale = const Locale('vi');
    }
    notifyListeners();
    _syncToBackend();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    _syncToBackend();
  }

  Future<void> _syncToBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    if (token.isNotEmpty) {
      await ApiService.updateUserLanguage(token, _locale.languageCode);
    }
  }

  void clearLocale() {
    _locale = const Locale('vi');
    notifyListeners();
  }
}
