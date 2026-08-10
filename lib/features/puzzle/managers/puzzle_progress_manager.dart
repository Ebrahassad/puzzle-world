import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';

class PuzzleProgressManager {
  PuzzleProgressManager._();

  //==================================================
  // 🔑 Keys
  //==================================================

  static const String progressKey = "puzzle_current_progress";

  static const String starsKey = "puzzle_total_stars";

  static const String coinsKey = "puzzle_coins";

  static const String gemsKey = "puzzle_gems";

  static const String hintsKey = "puzzle_hints";

  static const String lastWorldKey = "puzzle_last_world";

  static const String lastLevelKey = "puzzle_last_level";

  static const String completedLevelsKey = "puzzle_completed_levels";

  static const String claimedRewardsKey = "puzzle_claimed_rewards";

  static const String unlockedLevelsKey = "puzzle_unlocked_levels";

  static const String levelStarsKey = "puzzle_level_stars";

  static const String gameStateKey = "puzzle_game_state";

  static const String privateIslandGameStateKey =
      "private_island_game_state";

  static const String gamesPlayedKey = "puzzle_games_played";

  static const String totalMovesKey = "puzzle_total_moves";

  static const String bestTimeKey = "puzzle_best_time";

  static const String achievementsKey = "puzzle_achievements";

  static const String experienceKey = "puzzle_experience";

  static const String dailyMissionKey = "puzzle_daily_missions";

  static const String purchasedLevelsKey = "puzzle_purchased_levels";

  static const String purchasedIslandsKey = "puzzle_purchased_islands";

  static const String privateIslandKey = "private_island_unlocked";

  static const String adsBalanceKey = "puzzle_ads_balance";

  static const String purchasedStarsKey = "puzzle_star_unlocks";

  static const String purchasedGemsKey = "puzzle_gem_unlocks";

  static const String levelAdsKey = "puzzle_level_ads";

  static const String unlockedWorldsKey = "puzzle_unlocked_worlds";

  static const String unlockedIslandsKey = "puzzle_unlocked_islands";

  static const String firstDailyRewardClaimedKey =
      "puzzle_first_daily_reward_claimed";

  static const String privateIslandImagePathKey =
      "private_island_image_path";

  //==================================================
  // 💰 النظام الجديد - أسعار التحويل من الإعلانات
  //==================================================

  /// 50 مشاهدة إعلان = 100 عملة.
  static const int coinsPurchaseAdsCost = 50;

  static const int coinsPurchaseAmount = 100;

  /// 50 مشاهدة إعلان = نجمة واحدة.
  static const int starPurchaseAdsCost = 50;

  static const int starPurchaseAmount = 1;

  /// 100 مشاهدة إعلان = جوهرة واحدة.
  static const int gemPurchaseAdsCost = 100;

  static const int gemPurchaseAmount = 1;

  //==================================================
  // 📺 رصيد الإعلانات التجريبي
  //==================================================

  /// رصيد تجريبي مبدئي لاختبار عمليات الشراء داخل التطبيق.
  ///
  /// عند عدم وجود رصيد محفوظ في SharedPreferences،
  /// يبدأ اللاعب بـ 10000 مشاهدة إعلان.
  static const int initialAdsBalance = 10000;

  //==================================================
  // 🏝️ أسعار الجزيرة الخاصة
  //==================================================

  static const int privateIslandGemCost = 100;

  //==================================================
  // Preferences
  //==================================================

  static Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  //==================================================
  // 💾 حفظ حالة البازل الحالية
  //==================================================

  static Future<void> saveProgress({
    required String puzzleId,
    required String levelId,
    required List<PuzzlePiece> pieces,
    required int moves,
    required int seconds,
  }) async {
    final piecesData = pieces.map((piece) {
      return {
        "id": piece.id,
        "row": piece.row,
        "column": piece.col,

        // الموقع الحالي للقطعة
        "x": piece.currentPosition.dx,
        "y": piece.currentPosition.dy,

        // هل القطعة مثبتة في مكانها الصحيح؟
        "placed": piece.isPlaced,
      };
    }).toList();

    // بناء بيانات اللعبة كاملة قبل await
    final data = {
      "puzzleId": puzzleId,
      "levelId": levelId,
      "moves": moves,
      "seconds": seconds,
      "pieces": piecesData,
    };

    final prefs = await _prefs;

    await prefs.setString(
      progressKey,
      jsonEncode(data),
    );
  }

  //==================================================
  // 💾 حفظ Game State
  //==================================================

  static Future<void> saveGameState(
    Map<String, dynamic> state,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      gameStateKey,
      jsonEncode(state),
    );
  }

  static Future<Map<String, dynamic>?> loadGameState() async {
    final prefs = await _prefs;

    final value = prefs.getString(gameStateKey);

    if (value == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  //==================================================
  // 🏝️💾 حفظ حالة الجزيرة الخاصة
  //==================================================

  static Future<void> savePrivateIslandGameState(
    Map<String, dynamic> state,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      privateIslandGameStateKey,
      jsonEncode(state),
    );
  }

  //==================================================
  // 🏝️📖 قراءة حالة الجزيرة الخاصة
  //==================================================

  static Future<Map<String, dynamic>?>
      loadPrivateIslandGameState() async {
    final prefs = await _prefs;

    final value =
        prefs.getString(privateIslandGameStateKey);

    if (value == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  //==================================================
  // 🏝️🗑️ حذف حالة الجزيرة الخاصة
  //==================================================

  static Future<void>
      clearPrivateIslandGameState() async {
    final prefs = await _prefs;

    await prefs.remove(
      privateIslandGameStateKey,
    );
  }

  //==================================================
  // 🗑️ حذف حالة اللعبة الخاصة فقط
  //==================================================

  static Future<void> clearGameState() async {
    final prefs = await _prefs;

    await prefs.remove(gameStateKey);
  }

  //==================================================
  // 📖 قراءة حالة البازل
  //==================================================

  static Future<Map<String, dynamic>?> loadProgress() async {
    final prefs = await _prefs;

    final value = prefs.getString(progressKey);

    if (value == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  //==================================================
  // 🗑️ حذف حالة البازل
  //==================================================

  static Future<void> clearProgress() async {
    final prefs = await _prefs;

    await prefs.remove(progressKey);
  }

  // ... (بقية الملف كما هو دون تغيير)
  
  //==================================================
  // 🔄 إعادة ضبط التقدم
  //==================================================

  static Future<void> resetProgress() async {
    final prefs = await _prefs;

    await prefs.remove(progressKey);
    await prefs.remove(completedLevelsKey);
    await prefs.remove(unlockedLevelsKey);
    await prefs.remove(levelStarsKey);
    await prefs.remove(claimedRewardsKey);
    await prefs.remove(lastWorldKey);
    await prefs.remove(lastLevelKey);
    await prefs.remove(unlockedIslandsKey);
    await prefs.remove(adsBalanceKey);
    await prefs.remove(gameStateKey);
    await prefs.remove(privateIslandGameStateKey);
    await prefs.remove(levelAdsKey);
    await prefs.remove(purchasedLevelsKey);
    await prefs.remove(purchasedIslandsKey);
    await prefs.remove(purchasedStarsKey);
    await prefs.remove(purchasedGemsKey);
    await prefs.remove(privateIslandKey);
    await prefs.remove(privateIslandImagePathKey);
  }

  //==================================================
  // 🗑️ حذف كل بيانات اللاعب
  //==================================================

  static Future<void> resetAll() async {
    final prefs = await _prefs;

    await prefs.clear();
  }
}
