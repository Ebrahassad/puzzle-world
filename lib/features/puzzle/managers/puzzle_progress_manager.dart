import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';

class PuzzleProgressManager {
  PuzzleProgressManager._();

  //==================================================
  // المفاتيح
  //==================================================

  static const String progressKey = "puzzle_current_progress";

  static const String starsKey = "puzzle_stars";

  static const String coinsKey = "puzzle_coins";

  static const String gemsKey = "puzzle_gems";

  static const String hintsKey = "puzzle_hints";

  static const String completedLevelsKey =
      "puzzle_completed_levels";

  static const String unlockedLevelsKey =
      "puzzle_unlocked_levels";

  static const String claimedRewardsKey =
      "puzzle_claimed_rewards";

  static const String gamesPlayedKey =
      "puzzle_games_played";

  static const String totalMovesKey =
      "puzzle_total_moves";

  static const String bestTimeKey =
      "puzzle_best_time";

  static const String lastGameKey =
      "puzzle_last_game";

  static const String lastSessionKey =
      "puzzle_last_session";

  //==================================================
  // SharedPreferences
  //==================================================

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  //==================================================
  // حفظ اللعبة الحالية
  //==================================================

  static Future<void> saveProgress({
    required String puzzleId,
    required String levelId,
    required List<PuzzlePiece> pieces,
    required int moves,
    required int seconds,
  }) async {
    final prefs = await _prefs;

    final data = {
      "puzzleId": puzzleId,
      "levelId": levelId,
      "moves": moves,
      "seconds": seconds,
      "pieces": pieces
          .map(
            (piece) => {
              "id": piece.id,
              "row": piece.row,
              "column": piece.column,
              "x": piece.position.dx,
              "y": piece.position.dy,
              "placed": piece.placed,
            },
          )
          .toList(),
    };

    await prefs.setString(
      progressKey,
      jsonEncode(data),
    );
  }

  static Future<Map<String, dynamic>?> loadProgress() async {
    final prefs = await _prefs;

    final value = prefs.getString(progressKey);

    if (value == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(value),
    );
  }

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

  static Future<void> saveStars(int stars) async {
    final prefs = await _prefs;

    await prefs.setInt(
      starsKey,
      stars,
    );
  }

  static Future<void> addStars(int amount) async {
    final prefs = await _prefs;

    final current =
        prefs.getInt(starsKey) ?? 0;

    await prefs.setInt(
      starsKey,
      current + amount,
    );
  }

  //==================================================
  // 🪙 العملات
  //==================================================

  static Future<int> getCoins() async {
    final prefs = await _prefs;

    return prefs.getInt(coinsKey) ?? 0;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await _prefs;

    await prefs.setInt(
      coinsKey,
      coins,
    );
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await _prefs;

    final current =
        prefs.getInt(coinsKey) ?? 0;

    await prefs.setInt(
      coinsKey,
      current + amount,
    );
  }

  //==================================================
  // 💎 الجواهر
  //==================================================

  static Future<int> getGems() async {
    final prefs = await _prefs;

    return prefs.getInt(gemsKey) ?? 0;
  }

  static Future<void> saveGems(int gems) async {
    final prefs = await _prefs;

    await prefs.setInt(
      gemsKey,
      gems,
    );
  }

  static Future<void> addGems(int amount) async {
    final prefs = await _prefs;

    final current =
        prefs.getInt(gemsKey) ?? 0;

    await prefs.setInt(
      gemsKey,
      current + amount,
    );
  }

  //==================================================
  // 💡 التلميحات
  //==================================================

  static Future<int> getHints() async {
    final prefs = await _prefs;

    return prefs.getInt(hintsKey) ?? 0;
  }

  static Future<void> saveHints(int hints) async {
    final prefs = await _prefs;

    await prefs.setInt(
      hintsKey,
      hints,
    );
  }

  static Future<void> addHints(int amount) async {
    final prefs = await _prefs;

    final current =
        prefs.getInt(hintsKey) ?? 0;

    int value = current + amount;

    if (value < 0) {
      value = 0;
    }

    await prefs.setInt(
      hintsKey,
      value,
    );
  }

  static Future<bool> useHint() async {
    final prefs = await _prefs;

    final current =
        prefs.getInt(hintsKey) ?? 0;

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
    String levelId,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(completedLevelsKey) ?? [];

    if (!levels.contains(levelId)) {
      levels.add(levelId);
    }

    await prefs.setStringList(
      completedLevelsKey,
      levels,
    );
  }

  static Future<bool> isCompleted(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(completedLevelsKey) ?? [];

    return levels.contains(levelId);
  }

  static Future<int> getCompletedPuzzleCount() async {
    final prefs = await _prefs;

    return (prefs.getStringList(
              completedLevelsKey,
            ) ??
            [])
        .length;
  }

  static Future<void> restoreCompleted(
    int count,
  ) async {
    final prefs = await _prefs;

    final levels = List.generate(
      count,
      (index) => "restored_level_$index",
    );

    await prefs.setStringList(
      completedLevelsKey,
      levels,
    );
  }

  //==================================================
  // 🔓 فتح المراحل
  //==================================================

  static Future<void> unlockLevel(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(unlockedLevelsKey) ?? [];

    if (!levels.contains(levelId)) {
      levels.add(levelId);
    }

    await prefs.setStringList(
      unlockedLevelsKey,
      levels,
    );
  }

  static Future<bool> isUnlocked(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final levels =
        prefs.getStringList(unlockedLevelsKey) ?? [];

    // أول مرحلة في كل عالم مفتوحة دائماً
    if (levelId.endsWith("_level_1")) {
      return true;
    }

    return levels.contains(levelId);
  }

  static Future<void> unlockNextLevel(
    String currentLevelId,
  ) async {
    final data = currentLevelId.split("_level_");

    if (data.length != 2) return;

    final world = data[0];

    final current =
        int.tryParse(data[1]) ?? 1;

    final next =
        "${world}_level_${current + 1}";

    await unlockLevel(next);
  }

  //==================================================
  // 🎁 مكافآت المراحل
  //==================================================

  static Future<bool> isRewardClaimed(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final rewards =
        prefs.getStringList(claimedRewardsKey) ?? [];

    return rewards.contains(levelId);
  }

  static Future<void> markRewardClaimed(
    String levelId,
  ) async {
    final prefs = await _prefs;

    final rewards =
        prefs.getStringList(claimedRewardsKey) ?? [];

    if (!rewards.contains(levelId)) {
      rewards.add(levelId);
    }

    await prefs.setStringList(
      claimedRewardsKey,
      rewards,
    );
  }

  //==================================================
  // 🎮 آخر لعبة
  //==================================================

  static Future<void> saveLastGame(
    String gameId,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      lastGameKey,
      gameId,
    );
  }

  static Future<String?> getLastGame() async {
    final prefs = await _prefs;

    return prefs.getString(lastGameKey);
  }

  //==================================================
  // ⏱ آخر جلسة
  //==================================================

  static Future<void> saveLastSession(
    DateTime time,
  ) async {
    final prefs = await _prefs;

    await prefs.setString(
      lastSessionKey,
      time.toIso8601String(),
    );
  }

  static Future<DateTime?> getLastSession() async {
    final prefs = await _prefs;

    final value =
        prefs.getString(lastSessionKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  //==================================================
  // 📊 الإحصائيات
  //==================================================

  static Future<int> getGamesPlayed() async {
    final prefs = await _prefs;

    return prefs.getInt(gamesPlayedKey) ?? 0;
  }

  static Future<void> addGamePlayed() async {
    final prefs = await _prefs;

    final value =
        prefs.getInt(gamesPlayedKey) ?? 0;

    await prefs.setInt(
      gamesPlayedKey,
      value + 1,
    );
  }

  static Future<int> getTotalMoves() async {
    final prefs = await _prefs;

    return prefs.getInt(totalMovesKey) ?? 0;
  }

  static Future<int> getBestTime() async {
    final prefs = await _prefs;

    return prefs.getInt(bestTimeKey) ?? 0;
  }

  static Future<void> addCompletedPuzzle({
    required int stars,
    required int moves,
    required int seconds,
  }) async {
    final prefs = await _prefs;

    final totalMoves =
        prefs.getInt(totalMovesKey) ?? 0;

    await prefs.setInt(
      totalMovesKey,
      totalMoves + moves,
    );

    final best =
        prefs.getInt(bestTimeKey) ?? 0;

    if (best == 0 || seconds < best) {
      await prefs.setInt(
        bestTimeKey,
        seconds,
      );
    }

    await addGamePlayed();

    await addStars(stars);
  }

  //==================================================
  // إعادة تعيين الإحصائيات فقط
  //==================================================

  static Future<void> resetStatistics() async {
    final prefs = await _prefs;

    await prefs.remove(gamesPlayedKey);

    await prefs.remove(totalMovesKey);

    await prefs.remove(bestTimeKey);
  }

  //==================================================
  // إعادة ضبط كل بيانات البازل
  //==================================================

  static Future<void> resetAll() async {
    final prefs = await _prefs;

    await prefs.remove(progressKey);

    await prefs.remove(starsKey);

    await prefs.remove(coinsKey);

    await prefs.remove(gemsKey);

    await prefs.remove(hintsKey);

    await prefs.remove(completedLevelsKey);

    await prefs.remove(unlockedLevelsKey);

    await prefs.remove(claimedRewardsKey);

    await prefs.remove(gamesPlayedKey);

    await prefs.remove(totalMovesKey);

    await prefs.remove(bestTimeKey);

    await prefs.remove(lastGameKey);

    await prefs.remove(lastSessionKey);
  }
}