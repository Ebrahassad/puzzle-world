import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

import 'features/puzzle/managers/ads_manager.dart';
import 'features/puzzle/screens/world_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 🚀 تشغيل التطبيق مباشرة
  //
  // لا ننتظر Unity Ads هنا.
  // ============================================================

  runApp(
    const PuzzleWorldApp(),
  );
}

// ================================================================
// 🎮 Puzzle World App
// ================================================================

class PuzzleWorldApp extends StatelessWidget {
  const PuzzleWorldApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Puzzle World',

      // ==========================================================
      // 🎨 الثيم
      // ==========================================================

      theme: AppTheme.lightTheme.copyWith(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF4A247A),

          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),

          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          elevation: 8,
        ),
      ),

      // ==========================================================
      // 🌍 الشاشة الأولى
      // ==========================================================

      home: const _StartupScreen(),
    );
  }
}

// ================================================================
// 🚀 شاشة البداية
//
// تعرض WorldMapScreen مباشرة.
// وبعد أول إطار يتم تشغيل Unity Ads في الخلفية.
//
// هذا يمنع الإعلانات من تأخير ظهور التطبيق.
// ================================================================

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() =>
      _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  bool _adsStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _initializeAds();
      },
    );
  }

  Future<void> _initializeAds() async {
    if (_adsStarted) {
      return;
    }

    _adsStarted = true;

    try {
      await AdsManager().initAds();
    } catch (_) {
      // ========================================================
      // الإعلانات ليست شرطًا لتشغيل اللعبة.
      // إذا فشلت التهيئة، تستمر اللعبة بشكل طبيعي.
      // ========================================================
    }
  }

  @override
  Widget build(BuildContext context) {
    return const WorldMapScreen();
  }
}