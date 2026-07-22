import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_win_screen.dart';
import '../screens/wallet_screen.dart';

import '../screens/puzzle_settings_screen.dart';
import '../screens/puzzle_statistics_screen.dart';
import '../screens/puzzle_profile_screen.dart';
import '../screens/puzzle_achievement_screen.dart';
import '../screens/puzzle_shop_screen.dart';
import '../screens/puzzle_daily_reward_screen.dart';
import '../screens/puzzle_event_screen.dart';
import '../screens/puzzle_collection_screen.dart';

class PuzzleNavigationService {
  const PuzzleNavigationService._();

  // ===========================
  // الصفحة الرئيسية
  // ===========================

  static Future<T?> openHome<T>(
    BuildContext context,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleHomeScreen(),
      ),
      (route) => false,
    );
  }

  // ===========================
  // شاشة العالم
  // ===========================

  static Future<T?> openWorld<T>(
    BuildContext context, {
    required PuzzleModel puzzle,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleLevelScreen(
          puzzle: puzzle,
        ),
      ),
    );
  }

  // ===========================
  // شاشة المرحلة
  // ===========================

  static Future<T?> openGame<T>(
    BuildContext context, {
    required PuzzleModel puzzle,
    required PuzzleLevelModel level,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          puzzle: puzzle,
          level: level,
        ),
      ),
    );
  }

  // ===========================
  // شاشة الفوز
  // ===========================

  static Future<T?> openWin<T>(
    BuildContext context, {
    required GameResultModel result,
    required int difficulty,
    required String worldId,
    required int level,
  }) {
    return Navigator.pushReplacement<T, T>(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleWinScreen(
          result: result,
          difficulty: difficulty,
          worldId: worldId,
          level: level,
        ),
      ),
    );
  }

  // ===========================
  // المرحلة التالية
  // ===========================

  static Future<void> openNextLevel(
    BuildContext context, {
    required String worldId,
    required int currentLevel,
  }) async {
    // سيتم ربطه مع PuzzleWorldManager
    // وسيجلب PuzzleModel و PuzzleLevelModel تلقائياً.
  }

  // ===========================
  // إعادة المرحلة
  // ===========================

  static Future<void> restartLevel(
    BuildContext context, {
    required PuzzleModel puzzle,
    required PuzzleLevelModel level,
  }) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          puzzle: puzzle,
          level: level,
        ),
      ),
    );
  }

  // ===========================
  // المحفظة
  // ===========================

  static Future<T?> openWallet<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    );
  }

  // ===========================
  // المتجر
  // ===========================

  static Future<T?> openShop<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleShopScreen(),
      ),
    );
  }

  // ===========================
  // الإنجازات
  // ===========================

  static Future<T?> openAchievements<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleAchievementScreen(),
      ),
    );
  }

  // ===========================
  // الإحصائيات
  // ===========================

  static Future<T?> openStatistics<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleStatisticsScreen(),
      ),
    );
  }

  // ===========================
  // الملف الشخصي
  // ===========================

  static Future<T?> openProfile<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleProfileScreen(),
      ),
    );
  }

  // ===========================
  // الإعدادات
  // ===========================

  static Future<T?> openSettings<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleSettingsScreen(),
      ),
    );
  }

  // ===========================
  // المكافأة اليومية
  // ===========================

  static Future<T?> openDailyReward<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleDailyRewardScreen(),
      ),
    );
  }

  // ===========================
  // الأحداث
  // ===========================

  static Future<T?> openEvents<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleEventScreen(),
      ),
    );
  }

  // ===========================
  // مجموعة الصور
  // ===========================

  static Future<T?> openCollection<T>(
    BuildContext context,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleCollectionScreen(),
      ),
    );
  }

  // ===========================
  // الرجوع
  // ===========================

  static void back(
    BuildContext context, {
    dynamic result,
  }) {
    Navigator.pop(
      context,
      result,
    );
  }

  // ===========================
  // إغلاق جميع الصفحات
  // ===========================

  static void popToRoot(
    BuildContext context,
  ) {
    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
 