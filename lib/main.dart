import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/language/app_language_manager.dart';

import 'features/puzzle/managers/ads_manager.dart';
import 'features/puzzle/screens/world_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 🌐 تحميل اللغة المحفوظة
  // ============================================================

  await AppLanguageManager.instance.load();

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
    return ValueListenableBuilder<Locale>(
      valueListenable:
          AppLanguageManager.instance.localeNotifier,

      builder: (
        context,
        locale,
        child,
      ) {
        final bool isArabic =
            locale.languageCode == 'ar';

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Puzzle World',

          // ======================================================
          // 🌐 اللغة الحالية
          // ======================================================

          locale: locale,

          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],

          // ======================================================
          // 🧭 اتجاه التطبيق بالكامل
          // ======================================================

          builder: (
            context,
            child,
          ) {
            return Directionality(
              textDirection: isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },

          // ======================================================
          // 🎨 الثيم
          // ======================================================

          theme: AppTheme.lightTheme.copyWith(
            snackBarTheme: SnackBarThemeData(
              backgroundColor:
                  const Color(0xFF4A247A),

              contentTextStyle:
                  const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),

              behavior:
                  SnackBarBehavior.floating,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              elevation: 8,
            ),
          ),

          home: const WorldMapScreen(),
        );
      },
    );
  }
}