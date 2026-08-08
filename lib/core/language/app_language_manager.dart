import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageManager {
  static const String _languageKey = 'app_language';

  static final AppLanguageManager instance =
      AppLanguageManager._internal();

  AppLanguageManager._internal();

  // ============================================================
  // 🌐 اللغة الحالية
  // ============================================================

  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(
    const Locale('ar'),
  );

  // ============================================================
  // 🇦🇪 هل اللغة عربية؟
  // ============================================================

  bool get isArabic =>
      localeNotifier.value.languageCode == 'ar';

  // ============================================================
  // 🧭 اتجاه التطبيق
  // ============================================================

  TextDirection get textDirection =>
      isArabic
          ? TextDirection.rtl
          : TextDirection.ltr;

  // ============================================================
  // 📥 تحميل اللغة المحفوظة
  // ============================================================

  Future<void> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedLanguage =
        prefs.getString(_languageKey);

    if (savedLanguage == 'en') {
      localeNotifier.value =
          const Locale('en');
    } else {
      localeNotifier.value =
          const Locale('ar');
    }
  }

  // ============================================================
  // 🌐 تغيير اللغة
  // ============================================================

  Future<void> setLanguage(
    String languageCode,
  ) async {
    final language =
        languageCode == 'en'
            ? 'en'
            : 'ar';

    final locale =
        Locale(language);

    localeNotifier.value = locale;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _languageKey,
      language,
    );
  }

  // ============================================================
  // 🔄 تبديل اللغة
  // ============================================================

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setLanguage('en');
    } else {
      await setLanguage('ar');
    }
  }
}