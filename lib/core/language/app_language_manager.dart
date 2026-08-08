import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// 🌐 App Language Manager
///
/// مسؤول عن لغة التطبيق بالكامل.
/// اللغة يمكن تغييرها من WorldMapScreen فقط.
/// عند تغييرها يتم تحديث التطبيق بالكامل.
/// ============================================================

class AppLanguageManager {
  AppLanguageManager._internal();

  static final AppLanguageManager instance =
      AppLanguageManager._internal();

  // ============================================================
  // 💾 مفتاح حفظ اللغة
  // ============================================================

  static const String _languageKey = 'app_language';

  // ============================================================
  // 🌐 اللغة الحالية
  // ============================================================

  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(
    const Locale('ar'),
  );

  Locale get locale => localeNotifier.value;

  // ============================================================
  // 🔤 اللغة
  // ============================================================

  bool get isArabic =>
      locale.languageCode == 'ar';

  bool get isEnglish =>
      locale.languageCode == 'en';

  // ============================================================
  // 🧭 اتجاه التطبيق
  // ============================================================

  TextDirection get textDirection =>
      isArabic
          ? TextDirection.rtl
          : TextDirection.ltr;

  // ============================================================
  // 🚀 تحميل اللغة المحفوظة
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
      // العربية هي اللغة الافتراضية
      localeNotifier.value =
          const Locale('ar');
    }
  }

  // ============================================================
  // 🇸🇦 اختيار العربية
  // ============================================================

  Future<void> setArabic() async {
    await setLanguage('ar');
  }

  // ============================================================
  // 🇬🇧 اختيار الإنجليزية
  // ============================================================

  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  // ============================================================
  // 🌐 تغيير اللغة
  // ============================================================

  Future<void> setLanguage(
    String languageCode,
  ) async {
    final String language =
        languageCode == 'en'
            ? 'en'
            : 'ar';

    final Locale newLocale =
        Locale(language);

    // لا نعيد التحديث إذا كانت اللغة نفسها
    if (localeNotifier.value.languageCode ==
        language) {
      return;
    }

    // تحديث التطبيق مباشرة
    localeNotifier.value =
        newLocale;

    // حفظ اللغة
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
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  // ============================================================
  // 📝 ترجمة بسيطة داخل الشاشات
  // ============================================================

  String text({
    required String ar,
    required String en,
  }) {
    return isArabic ? ar : en;
  }
}