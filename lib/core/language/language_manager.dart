import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  static final LanguageManager instance = LanguageManager._internal();

  LanguageManager._internal();

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == 'en') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }

    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final language = languageCode == 'en' ? 'en' : 'ar';

    _locale = Locale(language);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _languageKey,
      language,
    );

    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setLanguage('en');
    } else {
      await setLanguage('ar');
    }
  }
}
