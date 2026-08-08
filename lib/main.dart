import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/language/language_manager.dart';

import 'features/puzzle/managers/ads_manager.dart';
import 'features/puzzle/screens/world_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 🌐 تحميل لغة التطبيق قبل تشغيل الواجهة
  // ============================================================

  await LanguageManager.instance.loadLanguage();

  // ============================================================
  // 📺 تهيئة الإعلانات
  // ============================================================

  await AdsManager().initAds();

  // ============================================================
  // 🚀 تشغيل التطبيق
  // ============================================================

  runApp(
    const PuzzleWorldApp(),
  );
}

class PuzzleWorldApp extends StatelessWidget {
  const PuzzleWorldApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageManager.instance,
      builder: (
        context,
        child,
      ) {
        final languageManager =
            LanguageManager.instance;

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "Puzzle World",

          theme: AppTheme.lightTheme,

          // ======================================================
          // 🌐 اللغة الحالية
          // ======================================================

          locale: languageManager.locale,

          // ======================================================
          // ↔️ اتجاه التطبيق بالكامل
          //
          // العربية  → RTL
          // الإنجليزية → LTR
          // ======================================================

          builder: (
            context,
            child,
          ) {
            return Directionality(
              textDirection:
                  languageManager.textDirection,
              child:
                  child ?? const SizedBox.shrink(),
            );
          },

          home:
              const WorldMapScreen(),
        );
      },
    );
  }
}