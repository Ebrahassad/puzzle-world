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
    // مهم جداً:
    // إنشاء نسخة كاملة من بيانات القطع قبل أي await.
    //
    // بهذا الشكل حتى لو تم dispose للـ PuzzleController
    // بعد استدعاء الحفظ، تكون بيانات القطع قد أصبحت
    // مستقلة عن controller.
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

    // بعد أن أصبحت البيانات في الذاكرة بشكل مستقل،
    // يمكن الآن الوصول إلى SharedPreferences.
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

  //==================================================
  // ⭐ النجوم
  //==================================================

  static Future<int> getStars() async {
    final prefs = await _prefs;

    return prefs.getInt(starsKey) ?? 0;
  }

  static Future<int> getTotalStars() async {
    return getStars();
  }

  static Future<void> addStars(int amount) async {
    if (amount == 0) {
      return;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(starsKey) ?? 0;

    final value = (current + amount).clamp(0, 999999999);

    await prefs.setInt(
      starsKey,
      value,
    );
  }

  static Future<void> saveStars(int value) async {
    final prefs = await _prefs;

    await prefs.setInt(
      starsKey,
      value < 0 ? 0 : value,
    );
  }

  static Future<void> saveLevelStars(
    String levelId,
    int stars,
  ) async {
    final prefs = await _prefs;

    Map<String, dynamic> data = {};

    try {
      final decoded = jsonDecode(
        prefs.getString(levelStarsKey) ?? "{}",
      );

      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    data[levelId] = stars;

    await prefs.setString(
      levelStarsKey,
      jsonEncode(data),
    );
  }

  static Future<int> getLevelStars(
    String levelId,
  ) async {
    final prefs = await _prefs;

    try {
      final decoded = jsonDecode(
        prefs.getString(levelStarsKey) ?? "{}",
      );

      if (decoded is Map) {
        final value = decoded[levelId];

        if (value is int) {
          return value;
        }

        if (value is num) {
          return value.toInt();
        }
      }
    } catch (_) {}

    return 0;
  }

  static Future<bool> spendStars(int amount) async {
    if (amount <= 0) {
      return false;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(starsKey) ?? 0;

    if (current < amount) {
      return false;
    }

    await prefs.setInt(
      starsKey,
      current - amount,
    );

    return true;
  }

  //==================================================
  // 🪙 العملات
  //==================================================

  static Future<int> getCoins() async {
    final prefs = await _prefs;

    return prefs.getInt(coinsKey) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    if (amount == 0) {
      return;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(coinsKey) ?? 0;

    final value = (current + amount).clamp(0, 999999999);

    await prefs.setInt(
      coinsKey,
      value,
    );
  }

  static Future<void> saveCoins(int value) async {
    final prefs = await _prefs;

    await prefs.setInt(
      coinsKey,
      value < 0 ? 0 : value,
    );
  }

  static Future<bool> spendCoins(int amount) async {
    if (amount <= 0) {
      return false;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(coinsKey) ?? 0;

    if (current < amount) {
      return false;
    }

    await prefs.setInt(
      coinsKey,
      current - amount,
    );

    return true;
  }

  //==================================================
  // 💎 الجواهر
  //==================================================

  static Future<int> getGems() async {
    final prefs = await _prefs;

    return prefs.getInt(gemsKey) ?? 0;
  }

  static Future<void> addGems(int amount) async {
    if (amount == 0) {
      return;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(gemsKey) ?? 0;

    final value = (current + amount).clamp(0, 999999999);

    await prefs.setInt(
      gemsKey,
      value,
    );
  }

  static Future<void> saveGems(int value) async {
    final prefs = await _prefs;

    await prefs.setInt(
      gemsKey,
      value < 0 ? 0 : value,
    );
  }

  static Future<bool> spendGems(int amount) async {
    if (amount <= 0) {
      return false;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(gemsKey) ?? 0;

    if (current < amount) {
      return false;
    }

    await prefs.setInt(
      gemsKey,
      current - amount,
    );

    return true;
  }

  //==================================================
  // 💡 التلميحات
  //==================================================

  static Future<int> getHints() async {
    final prefs = await _prefs;

    return prefs.getInt(hintsKey) ?? 0;
  }

  static Future<void> addHints(int amount) async {
    if (amount == 0) {
      return;
    }

    final prefs = await _prefs;

    final current = prefs.getInt(hintsKey) ?? 0;

    final value = (current + amount).clamp(0, 999999999);

    await prefs.setInt(
      hintsKey,
      value,
    );
  }

  static Future<bool> useHint() async {
    final prefs = await _prefs;

    final current = prefs.getInt(hintsKey) ?? 0;

    if (current <= 0) {
      return false;
    }

    await prefs.setInt(
      hintsKey,
      current - 1,
    );

    return true;
  }

  //==================================================
  // 🏆 المراحل المكتملة
  //==================================================

  static Future<void> completeLevel(
    String levelKey,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(completedLevelsKey) ?? [];

    if (!levels.contains(levelKey)) {
      levels.add(levelKey);

      await prefs.setStringList(
        completedLevelsKey,
        levels,
      );
    }
  }

  static Future<bool> isCompleted(
    String levelKey,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(completedLevelsKey) ?? [];

    return levels.contains(levelKey);
  }

  static Future<int> getCompletedCount() async {
    final prefs = await _prefs;

    return (prefs.getStringList(completedLevelsKey) ?? [])
        .length;
  }

  //==================================================
  // 🎁 المكافآت المستلمة
  //==================================================

  static Future<void> markRewardClaimed(
    String rewardKey,
  ) async {
    final prefs = await _prefs;

    final rewards =
        prefs.getStringList(claimedRewardsKey) ?? [];

    if (!rewards.contains(rewardKey)) {
      rewards.add(rewardKey);

      await prefs.setStringList(
        claimedRewardsKey,
        rewards,
      );
    }
  }

  static Future<bool> isRewardClaimed(
    String rewardKey,
  ) async {
    final prefs = await _prefs;

    final rewards =
        prefs.getStringList(claimedRewardsKey) ?? [];

    return rewards.contains(rewardKey);
  }

  //==================================================
  // 🪙 أسعار فتح المراحل بالعملات
  //==================================================

  static int getLevelCoinCost(int level) {
    if (level <= 1) {
      return 0;
    }

    switch (level) {
      case 2:
        return 75;

      case 3:
        return 150;

      case 4:
        return 250;

      case 5:
        return 350;

      case 6:
        return 450;

      case 7:
        return 600;

      case 8:
        return 750;

      case 9:
        return 875;

      case 10:
        return 1000;

      default:
        return 1000;
    }
  }

  //==================================================
  // ⭐ أسعار فتح المراحل بالنجوم
  //==================================================

  static int getLevelStarCost(int level) {
    if (level <= 1) {
      return 0;
    }

    return 2 + ((level - 2) ~/ 3);
  }

  //==================================================
  // 💎 أسعار فتح المراحل بالجواهر
  //==================================================

  static int getLevelGemCost(int level) {
    if (level <= 1) {
      return 0;
    }

    return 1 + ((level - 2) ~/ 5);
  }

  //==================================================
  // 🏝️ أسعار فتح الجزر بالنجوم
  //==================================================

  static int getIslandStarCost(
    String islandId,
  ) {
    switch (islandId) {
      case "animals":
        return 0;

      case "nature":
        return 50;

      case "cars":
        return 75;

      case "landmarks":
        return 100;

      case "space":
        return 150;

      default:
        return 999999;
    }
  }

  //==================================================
  // ⭐ شراء الجزيرة بالنجوم
  //==================================================

  static Future<bool> buyIslandWithStars(
    String islandId,
  ) async {
    // الحيوانات مفتوحة دائماً.
    if (islandId == "animals") {
      await unlockIsland(islandId);
      return true;
    }

    final unlocked =
        await isIslandUnlocked(islandId);

    if (unlocked) {
      return true;
    }

    final cost =
        getIslandStarCost(islandId);

    if (cost <= 0) {
      return false;
    }

    final paid =
        await spendStars(cost);

    if (!paid) {
      return false;
    }

    await unlockIsland(islandId);

    final prefs = await _prefs;

    final purchased =
        prefs.getStringList(purchasedIslandsKey) ?? [];

    if (!purchased.contains(islandId)) {
      purchased.add(islandId);

      await prefs.setStringList(
        purchasedIslandsKey,
        purchased,
      );
    }

    return true;
  }

  //==================================================
  // 🔓 فتح المراحل
  //==================================================

  static Future<void> unlockLevel(
    String levelKey,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(unlockedLevelsKey) ?? [];

    if (!levels.contains(levelKey)) {
      levels.add(levelKey);

      await prefs.setStringList(
        unlockedLevelsKey,
        levels,
      );
    }
  }

  static Future<bool> isLevelUnlocked(
    String levelKey,
  ) async {
    // المستوى الأول في كل جزيرة مفتوح تلقائياً.
    if (levelKey.endsWith("_level_1")) {
      return true;
    }

    final prefs = await _prefs;

    final levels =
        prefs.getStringList(unlockedLevelsKey) ?? [];

    return levels.contains(levelKey);
  }

  static Future<void> unlockNextLevel(
    String worldId,
    int currentLevel,
  ) async {
    await unlockLevel(
      "${worldId}_level_${currentLevel + 1}",
    );
  }

  //==================================================
  // 🪙 شراء المرحلة بالعملات
  //==================================================

  static Future<bool> buyLevelWithCoins(
    String levelId,
    int levelNumber,
  ) async {
    if (levelNumber <= 1) {
      await unlockLevel(levelId);
      return true;
    }

    final unlocked =
        await isLevelUnlocked(levelId);

    if (unlocked) {
      return true;
    }

    final cost =
        getLevelCoinCost(levelNumber);

    if (cost <= 0) {
      return false;
    }

    final paid =
        await spendCoins(cost);

    if (!paid) {
      return false;
    }

    await unlockLevel(levelId);

    final prefs = await _prefs;

    final purchased =
        prefs.getStringList(purchasedLevelsKey) ?? [];

    if (!purchased.contains(levelId)) {
      purchased.add(levelId);

      await prefs.setStringList(
        purchasedLevelsKey,
        purchased,
      );
    }

    return true;
  }

  //==================================================
  // 🔍 هل المرحلة مشتراة؟
  //==================================================

  static Future<bool> isLevelPurchased(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(purchasedLevelsKey) ?? [];

    return levels.contains(levelId);
  }

  //==================================================
  // ⭐ شراء المرحلة بالنجوم
  //==================================================

  static Future<bool> buyLevelWithStars(
    String levelId,
    int levelNumber,
  ) async {
    if (levelNumber <= 1) {
      await unlockLevel(levelId);
      return true;
    }

    final unlocked =
        await isLevelUnlocked(levelId);

    if (unlocked) {
      return true;
    }

    final cost =
        getLevelStarCost(levelNumber);

    if (cost <= 0) {
      return false;
    }

    final paid =
        await spendStars(cost);

    if (!paid) {
      return false;
    }

    await unlockLevel(levelId);

    await saveStarPurchase(levelId);

    return true;
  }

  //==================================================
  // 💎 شراء المرحلة بالجواهر
  //==================================================

  static Future<bool> buyLevelWithGems(
    String levelId,
    int levelNumber,
  ) async {
    if (levelNumber <= 1) {
      await unlockLevel(levelId);
      return true;
    }

    final unlocked =
        await isLevelUnlocked(levelId);

    if (unlocked) {
      return true;
    }

    final cost =
        getLevelGemCost(levelNumber);

    if (cost <= 0) {
      return false;
    }

    final paid =
        await spendGems(cost);

    if (!paid) {
      return false;
    }

    await unlockLevel(levelId);

    await saveGemPurchase(levelId);

    return true;
  }

  //==================================================
  // 🌍 فتح العوالم
  //==================================================

  static Future<void> unlockWorld(
    String worldId,
  ) async {
    final prefs = await _prefs;

    final worlds =
        prefs.getStringList(unlockedWorldsKey) ?? [];

    if (!worlds.contains(worldId)) {
      worlds.add(worldId);

      await prefs.setStringList(
        unlockedWorldsKey,
        worlds,
      );
    }
  }

  static Future<bool> isWorldUnlocked(
    String worldId,
  ) async {
    if (worldId == "world_1") {
      return true;
    }

    final prefs = await _prefs;

    final worlds =
        prefs.getStringList(unlockedWorldsKey) ?? [];

    return worlds.contains(worldId);
  }

  static Future<void> unlockAllLevels(
    String worldId,
  ) async {
    for (int i = 1; i <= 100; i++) {
      await unlockLevel(
        "${worldId}_level_$i",
      );
    }
  }

  //==================================================
  // ⭐ حفظ شراء النجوم
  //==================================================

  static Future<void> saveStarPurchase(
    String id,
  ) async {
    final prefs = await _prefs;

    final list =
        prefs.getStringList(purchasedStarsKey) ?? [];

    if (!list.contains(id)) {
      list.add(id);

      await prefs.setStringList(
        purchasedStarsKey,
        list,
      );
    }
  }

  //==================================================
  // 💎 حفظ شراء الجواهر
  //==================================================

  static Future<void> saveGemPurchase(
    String id,
  ) async {
    final prefs = await _prefs;

    final list =
        prefs.getStringList(purchasedGemsKey) ?? [];

    if (!list.contains(id)) {
      list.add(id);

      await prefs.setStringList(
        purchasedGemsKey,
        list,
      );
    }
  }

  //==================================================
  // 💎 استخدام الجواهر للفتح
  //==================================================

  static Future<bool> useGemsForUnlock(
    int amount,
  ) async {
    return spendGems(amount);
  }

  //==================================================
  // 🎮 آخر مستوى لعب
  //==================================================

  static Future<void> saveLastPuzzle(
    String worldId,
    String levelId,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      lastWorldKey,
      worldId,
    );

    await prefs.setString(
      lastLevelKey,
      levelId,
    );
  }

  static Future<Map<String, String>?> getLastPuzzle() async {
    final prefs = await _prefs;

    final world =
        prefs.getString(lastWorldKey);

    final level =
        prefs.getString(lastLevelKey);

    if (world == null || level == null) {
      return null;
    }

    return {
      "worldId": world,
      "levelId": level,
    };
  }

  //==================================================
  // 📊 إحصائيات اللاعب
  //==================================================

  static Future<int> getGamesPlayed() async {
    final prefs = await _prefs;

    return prefs.getInt(gamesPlayedKey) ?? 0;
  }

  static Future<int> getTotalMoves() async {
    final prefs = await _prefs;

    return prefs.getInt(totalMovesKey) ?? 0;
  }

  static Future<void> addTotalMoves(
    int moves,
  ) async {
    if (moves <= 0) {
      return;
    }

    final prefs = await _prefs;

    final current =
        prefs.getInt(totalMovesKey) ?? 0;

    await prefs.setInt(
      totalMovesKey,
      current + moves,
    );
  }

  static Future<int> getBestTime() async {
    final prefs = await _prefs;

    return prefs.getInt(bestTimeKey) ?? 0;
  }

  static Future<void> addCompletedPuzzle({
    required int moves,
    required int seconds,
  }) async {
    final prefs = await _prefs;

    final oldMoves =
        prefs.getInt(totalMovesKey) ?? 0;

    await prefs.setInt(
      totalMovesKey,
      oldMoves + moves,
    );

    final oldGames =
        prefs.getInt(gamesPlayedKey) ?? 0;

    await prefs.setInt(
      gamesPlayedKey,
      oldGames + 1,
    );

    final best =
        prefs.getInt(bestTimeKey) ?? 0;

    if (best == 0 || seconds < best) {
      await prefs.setInt(
        bestTimeKey,
        seconds,
      );
    }
  }

  //==================================================
  // 🏆 الإنجازات
  //==================================================

  static Future<void> saveAchievement(
    String id,
  ) async {
    final prefs = await _prefs;

    final list =
        prefs.getStringList(achievementsKey) ?? [];

    if (!list.contains(id)) {
      list.add(id);

      await prefs.setStringList(
        achievementsKey,
        list,
      );
    }
  }

  static Future<bool> hasAchievement(
    String id,
  ) async {
    final prefs = await _prefs;

    final list =
        prefs.getStringList(achievementsKey) ?? [];

    return list.contains(id);
  }

  //==================================================
  // 🎯 المهام اليومية
  //==================================================

  static Future<List<Map<String, dynamic>>>
      getDailyMissions() async {
    final prefs = await _prefs;

    try {
      final data = jsonDecode(
        prefs.getString(dailyMissionKey) ?? "[]",
      );

      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }
    } catch (_) {}

    return [];
  }

  static Future<void> saveDailyMissions(
    List<Map<String, dynamic>> missions,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      dailyMissionKey,
      jsonEncode(missions),
    );
  }

  //==================================================
  // ⭐ الخبرة XP
  //==================================================

  static Future<void> addExperience(
    int amount,
  ) async {
    if (amount <= 0) {
      return;
    }

    final prefs = await _prefs;

    final current =
        prefs.getInt(experienceKey) ?? 0;

    await prefs.setInt(
      experienceKey,
      current + amount,
    );
  }

  static Future<int> getExperience() async {
    final prefs = await _prefs;

    return prefs.getInt(experienceKey) ?? 0;
  }

  //==================================================
  // 📺 رصيد الإعلانات العام
  //==================================================

  /// هذا الرصيد يمثل عدد الإعلانات المكتملة.
  ///
  /// مهم:
  /// AdsManager هو المسؤول عن إضافة مشاهدة واحدة
  /// عند اكتمال الإعلان بنجاح.
  ///
  /// لا تقم باستدعاء addAdsBalance مرة ثانية
  /// من WorldMapScreen أو WalletScreen.
  static Future<int> getAdsBalance() async {
    final prefs = await _prefs;

    return prefs.getInt(adsBalanceKey) ??
        initialAdsBalance;
  }

  static Future<void> addAdsBalance(
    int amount,
  ) async {
    if (amount <= 0) {
      return;
    }

    final prefs = await _prefs;

    final current =
        prefs.getInt(adsBalanceKey) ?? 0;

    await prefs.setInt(
      adsBalanceKey,
      current + amount,
    );
  }

  static Future<bool> spendAdsBalance(
    int amount,
  ) async {
    if (amount <= 0) {
      return false;
    }

    final prefs = await _prefs;

    final current =
        prefs.getInt(adsBalanceKey) ??
            initialAdsBalance;

    if (current < amount) {
      return false;
    }

    await prefs.setInt(
      adsBalanceKey,
      current - amount,
    );

    return true;
  }

  //==================================================
  // 📺➡️🪙 شراء العملات برصيد الإعلانات
  //==================================================

  static Future<bool> buyCoinsWithAds() async {
    final paid = await spendAdsBalance(
      coinsPurchaseAdsCost,
    );

    if (!paid) {
      return false;
    }

    await addCoins(
      coinsPurchaseAmount,
    );

    return true;
  }

  //==================================================
  // 📺➡️⭐ شراء نجمة برصيد الإعلانات
  //==================================================

  static Future<bool> buyStarWithAds() async {
    final paid = await spendAdsBalance(
      starPurchaseAdsCost,
    );

    if (!paid) {
      return false;
    }

    await addStars(
      starPurchaseAmount,
    );

    return true;
  }

  //==================================================
  // 📺➡️💎 شراء جوهرة برصيد الإعلانات
  //==================================================

  static Future<bool> buyGemWithAds() async {
    final paid = await spendAdsBalance(
      gemPurchaseAdsCost,
    );

    if (!paid) {
      return false;
    }

    await addGems(
      gemPurchaseAmount,
    );

    return true;
  }

  //==================================================
  // 🎁🎉 مكافأة البداية
  //==================================================

  static Future<bool> claimFirstDailyReward() async {
    final prefs = await _prefs;

    // إذا تم استلام مكافأة البداية سابقاً
    // لا يتم منحها مرة أخرى.
    final alreadyClaimed =
        prefs.getBool(firstDailyRewardClaimedKey) ?? false;

    if (alreadyClaimed) {
      return false;
    }

    //==================================================
    // 🎁 مكافأة البداية
    //==================================================
    // 📺 500 رصيد مشاهدات
    // ⭐ 10 نجوم
    // 💎 5 جواهر
    //==================================================

    await addAdsBalance(500);

    await addStars(10);

    await addGems(5);

    // تسجيل أن مكافأة البداية تم استلامها.
    await prefs.setBool(
      firstDailyRewardClaimedKey,
      true,
    );

    return true;
  }

  //==================================================
  // 🏝️ نظام الجزر
  //==================================================

  static Future<void> unlockIsland(
    String islandId,
  ) async {
    final prefs = await _prefs;

    final islands =
        prefs.getStringList(unlockedIslandsKey) ?? [];

    if (!islands.contains(islandId)) {
      islands.add(islandId);

      await prefs.setStringList(
        unlockedIslandsKey,
        islands,
      );
    }
  }

  static Future<bool> isIslandUnlocked(
    String islandId,
  ) async {
    // الحيوانات مفتوحة دائماً.
    if (islandId == "animals") {
      return true;
    }

    final prefs = await _prefs;

    final islands =
        prefs.getStringList(unlockedIslandsKey) ?? [];

    return islands.contains(islandId);
  }

  //==================================================
  // 🏝️ فتح الجزيرة التالية
  //==================================================

  static Future<void> unlockNextIsland(
    String currentIsland,
  ) async {
    switch (currentIsland) {
      case "animals":
        await unlockIsland("nature");
        break;

      case "nature":
        await unlockIsland("cars");
        break;

      case "cars":
        await unlockIsland("landmarks");
        break;

      case "landmarks":
        await unlockIsland("space");
        break;

      // لا يتم فتح الجزيرة الخاصة تلقائياً.
      //
      // الجزيرة الخاصة لها نظام شراء مستقل:
      // 100 جوهرة.
      case "space":
        break;
    }
  }

  //==================================================
  // 🏝️ الجزيرة الخاصة
  //==================================================

  static Future<bool> buyPrivateIslandWithGems() async {
    final prefs = await _prefs;

    final alreadyUnlocked =
        prefs.getBool(privateIslandKey) ?? false;

    if (alreadyUnlocked) {
      return true;
    }

    final paid =
        await spendGems(privateIslandGemCost);

    if (!paid) {
      return false;
    }

    await prefs.setBool(
      privateIslandKey,
      true,
    );

    return true;
  }

  static Future<bool> isPrivateIslandUnlocked() async {
    final prefs = await _prefs;

    return prefs.getBool(
          privateIslandKey,
        ) ??
        false;
  }

  //==================================================
  // 🏝️📸 صورة الجزيرة الخاصة المؤقتة
  //==================================================

  /// حفظ مسار صورة الجزيرة الخاصة مؤقتاً.
  static Future<void> savePrivateIslandImagePath(
    String imagePath,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      privateIslandImagePathKey,
      imagePath,
    );
  }

  /// الحصول على مسار صورة الجزيرة الخاصة المحفوظة.
  static Future<String?> getPrivateIslandImagePath() async {
    final prefs = await _prefs;

    return prefs.getString(
      privateIslandImagePathKey,
    );
  }

  /// حذف صورة الجزيرة الخاصة من الجهاز
  /// وحذف مسارها من SharedPreferences.
  ///
  /// يتم استدعاؤها فقط بعد إكمال البازل بنجاح.
  static Future<void> clearPrivateIslandImage() async {
    final prefs = await _prefs;

    final imagePath = prefs.getString(
      privateIslandImagePathKey,
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);

        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // إذا فشل حذف الملف لا نوقف اللعبة.
      }
    }

    await prefs.remove(
      privateIslandImagePathKey,
    );
  }

  //==================================================
  // ⚙️ الإعدادات
  //==================================================

  static const String soundKey = "puzzle_sound";

  static const String vibrationKey = "puzzle_vibration";

  static const String darkModeKey = "puzzle_dark_mode";

  static Future<bool> isSoundEnabled() async {
    return (await _prefs).getBool(soundKey) ?? true;
  }

  static Future<void> saveSoundEnabled(
    bool value,
  ) async {
    await (await _prefs).setBool(
      soundKey,
      value,
    );
  }

  static Future<bool> isVibrationEnabled() async {
    return (await _prefs).getBool(vibrationKey) ?? true;
  }

  static Future<void> saveVibrationEnabled(
    bool value,
  ) async {
    await (await _prefs).setBool(
      vibrationKey,
      value,
    );
  }

  static Future<bool> isDarkMode() async {
    return (await _prefs).getBool(darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(
    bool value,
  ) async {
    await (await _prefs).setBool(
      darkModeKey,
      value,
    );
  }

  //==================================================
  // 💾 تصدير البيانات
  //==================================================

  static Future<Map<String, dynamic>> exportData() async {
    final prefs = await _prefs;

    final data = <String, dynamic>{};

    for (final key in prefs.getKeys()) {
      data[key] = prefs.get(key);
    }

    return data;
  }

  //==================================================
  // 📥 استيراد البيانات
  //==================================================

  static Future<void> importData(
    Map<String, dynamic> data,
  ) async {
    final prefs = await _prefs;

    for (final item in data.entries) {
      final value = item.value;

      if (value is int) {
        await prefs.setInt(
          item.key,
          value,
        );
      } else if (value is double) {
        await prefs.setDouble(
          item.key,
          value,
        );
      } else if (value is bool) {
        await prefs.setBool(
          item.key,
          value,
        );
      } else if (value is String) {
        await prefs.setString(
          item.key,
          value,
        );
      } else if (value is List) {
        final stringList = value
            .whereType<String>()
            .toList();

        if (stringList.length == value.length) {
          await prefs.setStringList(
            item.key,
            stringList,
          );
        }
      }
    }
  }

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
