import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';

import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';

class PuzzleLevelService {
  const PuzzleLevelService._();

  //==================================================
  // تحميل مستويات العالم
  //==================================================

  static Future<List<PuzzleLevelModel>> getLevels(
    String worldId,
  ) async {
    return PuzzleLevelData.getLevels(worldId);
  }

  //==================================================
  // عدد مستويات العالم
  //==================================================

  static Future<int> getLevelCount(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    return levels.length;
  }

  //==================================================
  // مستوى واحد
  //==================================================

  static Future<PuzzleLevelModel?> getLevel(
    String worldId,
    int levelNumber,
  ) async {
    final levels = await getLevels(worldId);

    final index = levelNumber - 1;

    if (index < 0 || index >= levels.length) {
      return null;
    }

    return levels[index];
  }

  //==================================================
  // التحقق من وجود المستوى
  //==================================================

  static Future<bool> levelExists(
    String worldId,
    int levelNumber,
  ) async {
    return await getLevel(
          worldId,
          levelNumber,
        ) !=
        null;
  }

  //==================================================
  // إجمالي النجوم
  //==================================================

  static Future<int> getTotalStars() async {
    return PuzzleProgressManager.getTotalStars();
  }

  //==================================================
  // فتح المستوى
  //==================================================

  static Future<bool> isLevelUnlocked({
    required String worldId,
    required PuzzleLevelModel level,
  }) async {
    return PuzzleProgressManager.isUnlocked(
      "${worldId}_${level.id}",
    );
  }

  //==================================================
  // هل يمكن لعب المستوى
  //==================================================

  static Future<bool> canPlayLevel({
    required String worldId,
    required PuzzleLevelModel level,
  }) async {
    return isLevelUnlocked(
      worldId: worldId,
      level: level,
    );
  }

  //==================================================
  // المستويات المفتوحة
  //==================================================

  static Future<List<PuzzleLevelModel>> getUnlockedLevels(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    final result = <PuzzleLevelModel>[];

    for (final level in levels) {
      final unlocked = await isLevelUnlocked(
        worldId: worldId,
        level: level,
      );

      if (unlocked) {
        result.add(level);
      }
    }

    return result;
  }

  //==================================================
  // عدد المستويات المكتملة
  //==================================================

  static Future<int> getCompletedCount(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    int completed = 0;

    for (final level in levels) {
      final done = await PuzzleProgressManager.isCompleted(
        "${worldId}_${level.id}",
      );

      if (done) {
        completed++;
      }
    }

    return completed;
  }

  //==================================================
  // نسبة الإنجاز
  //==================================================

  static Future<double> getProgress(
    String worldId,
  ) async {
    final total = await getLevelCount(worldId);

    if (total == 0) {
      return 0;
    }

    final completed = await getCompletedCount(worldId);

    return completed / total;
  }

  //==================================================
  // فتح شاشة المستوى
  //==================================================

  static Future<void> openLevel(
    BuildContext context, {
    required PuzzleModel world,
    required PuzzleLevelModel level,
  }) async {
    final allowed = await canPlayLevel(
      worldId: world.id,
      level: level,
    );

    if (!allowed) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          puzzle: world,
          level: level,
        ),
      ),
    );
  }

  //==================================================
  // شاشة مستويات العالم
  //==================================================

  static Future<void> openWorldLevels(
    BuildContext context, {
    required PuzzleModel world,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleLevelScreen(
          puzzle: world,
        ),
      ),
    );
  }
  //==================================================
  // الرجوع للرئيسية
  //==================================================

  static Future<void> backToPuzzleHome(
    BuildContext context,
  ) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleHomeScreen(),
      ),
      (route) => false,
    );
  }

  //==================================================
  // إنهاء مستوى
  //==================================================

  static Future<void> completeLevel({
    required String worldId,
    required int levelNumber,
    required int stars,
  }) async {
    final levelKey = "${worldId}_level_$levelNumber";

    final completed =
        await PuzzleProgressManager.isCompleted(levelKey);

    if (completed) {
      return;
    }

    await PuzzleProgressManager.completeLevel(levelKey);

    await PuzzleProgressManager.addStars(stars);

    await unlockNextLevel(
      worldId: worldId,
      currentLevel: levelNumber,
    );
  }

  //==================================================
  // فتح المستوى التالي
  //==================================================

  static Future<void> unlockNextLevel({
    required String worldId,
    required int currentLevel,
  }) async {
    await PuzzleProgressManager.unlockNextLevel(
      worldId,
      currentLevel,
    );
  }

  //==================================================
  // هل المستوى مكتمل
  //==================================================

  static Future<bool> isCompleted({
    required String worldId,
    required int levelNumber,
  }) async {
    return PuzzleProgressManager.isCompleted(
      "${worldId}_level_$levelNumber",
    );
  }

  //==================================================
  // نجوم المستوى
  //==================================================

  static Future<int> getLevelStars({
    required String worldId,
    required int levelNumber,
  }) async {
    return PuzzleProgressManager.getLevelStars(
      "${worldId}_level_$levelNumber",
    );
  }

  static Future<void> saveLevelStars({
    required String worldId,
    required int levelNumber,
    required int stars,
  }) async {
    final key = "${worldId}_level_$levelNumber";

    final oldStars =
        await PuzzleProgressManager.getLevelStars(key);

    if (stars > oldStars) {
      await PuzzleProgressManager.saveLevelStars(
        key,
        stars,
      );
    }
  }

  //==================================================
  // مكافأة المستوى
  //==================================================

  static Future<void> claimLevelReward({
    required String worldId,
    required int levelNumber,
    required int difficulty,
  }) async {
    final rewardKey =
        "${worldId}_level_$levelNumber";

    final claimed =
        await PuzzleProgressManager.isRewardClaimed(
      rewardKey,
    );

    if (claimed) {
      return;
    }

    await RewardManager.completePuzzle(
      difficulty: difficulty,
    );

    await PuzzleProgressManager.markRewardClaimed(
      rewardKey,
    );
  }

  //==================================================
  // إنهاء المستوى بالكامل
  //==================================================

  static Future<void> finishLevel({
    required String worldId,
    required int levelNumber,
    required int stars,
    required int difficulty,
  }) async {
    await completeLevel(
      worldId: worldId,
      levelNumber: levelNumber,
      stars: stars,
    );

    await saveLevelStars(
      worldId: worldId,
      levelNumber: levelNumber,
      stars: stars,
    );

    await claimLevelReward(
      worldId: worldId,
      levelNumber: levelNumber,
      difficulty: difficulty,
    );
  }

  //==================================================
  // هل العالم مكتمل
  //==================================================

  static Future<bool> isWorldCompleted(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    for (final level in levels) {
      final number = int.parse(
        level.id.replaceAll("level_", ""),
      );

      if (!await isCompleted(
        worldId: worldId,
        levelNumber: number,
      )) {
        return false;
      }
    }

    return true;
  }

  //==================================================
  // مجموع نجوم العالم
  //==================================================

  static Future<int> getWorldStars(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    int total = 0;

    for (final level in levels) {
      final number = int.parse(
        level.id.replaceAll("level_", ""),
      );

      total += await getLevelStars(
        worldId: worldId,
        levelNumber: number,
      );
    }

    return total;
  }
  //==================================================
  // إحصائيات العالم
  //==================================================

  static Future<Map<String, dynamic>> getWorldStatistics(
    String worldId,
  ) async {
    final levels = await getLevels(worldId);

    int completedLevels = 0;
    int totalStars = 0;

    for (final level in levels) {
      final number = int.parse(
        level.id.replaceAll(
          "level_",
          "",
        ),
      );

      if (await isCompleted(
        worldId: worldId,
        levelNumber: number,
      )) {
        completedLevels++;
      }

      totalStars += await getLevelStars(
        worldId: worldId,
        levelNumber: number,
      );
    }

    return {
      "worldId": worldId,
      "totalLevels": levels.length,
      "completedLevels": completedLevels,
      "stars": totalStars,
      "progress": levels.isEmpty
          ? 0.0
          : completedLevels / levels.length,
    };
  }

  //==================================================
  // حفظ آخر مستوى تم لعبه
  //==================================================

  static Future<void> saveLastPlayed({
    required String worldId,
    required int level,
  }) async {
    await PuzzleProgressManager.saveLastPuzzle(
      worldId,
      "${worldId}_level_$level",
    );
  }

  //==================================================
  // آخر مستوى
  //==================================================

  static Future<Map<String, dynamic>?> getLastPlayed() async {
    return PuzzleProgressManager.getLastPuzzle();
  }


  //========================================
  // إكمال المستوى
  //========================================

  static Future<void> finishLevel({
    required String worldId,
    required PuzzleLevelModel level,
    required int stars,
    required int moves,
    required int seconds,
  }) async {
    final levelKey = "${worldId}_${level.id}";

    await PuzzleProgressManager.completeLevel(levelKey);

    await PuzzleProgressManager.saveLevelStars(
      levelKey,
      stars,
    );

    await PuzzleProgressManager.addStars(stars);

    await PuzzleProgressManager.addCompletedPuzzle(
      stars: stars,
      moves: moves,
      seconds: seconds,
    );

    await PuzzleProgressManager.unlockNextLevel(
      worldId,
      level.levelNumber,
    );
  }


  //==================================================
  // حفظ آخر مستوى تم لعبه
  //==================================================

  static Future<void> saveLastPlayed({
    required String worldId,
    required int levelNumber,
  }) async {
    await PuzzleProgressManager.saveLastPuzzle(
      worldId,
      "${worldId}_level_$levelNumber",
    );
  }

  //==================================================
  // آخر مستوى تم لعبه
  //==================================================

  static Future<Map<String, dynamic>?> getLastPlayed() async {
    return await PuzzleProgressManager.getLastPuzzle();
  }

  //==================================================
  // إعادة تعيين تقدم عالم
  //==================================================

  static Future<void> resetWorldProgress({
    required String worldId,
  }) async {
    await PuzzleProgressManager.resetWorld(worldId);
  }

  //==================================================
  // إعادة تعيين جميع بيانات البازل
  //==================================================

  static Future<void> resetAllPuzzleData() async {
    await PuzzleProgressManager.resetPuzzleData();
  }

  //==================================================
  // تصدير البيانات
  //==================================================

  static Future<Map<String, dynamic>> exportPuzzleData() async {
    return await PuzzleProgressManager.exportData();
  }

  //==================================================
  // استيراد البيانات
  //==================================================

  static Future<void> importPuzzleData(
    Map<String, dynamic> data,
  ) async {
    await PuzzleProgressManager.importData(data);
  }

  //==================================================
  // الإنجازات
  //==================================================

  static Future<void> saveAchievement({
    required String id,
  }) async {
    await PuzzleProgressManager.saveAchievement(
      id,
    );
  }


  static Future<bool> hasAchievement({
    required String id,
  }) async {
    return await PuzzleProgressManager.hasAchievement(
      id,
    );
  }


  static Future<void> checkAchievements({
    required String worldId,
  }) async {

    final completed =
        await getCompletedCount(
          worldId,
        );


    if (completed >= 5) {
      await saveAchievement(
        id: "puzzle_master",
      );
    }


    final stars =
        await getWorldStars(
          worldId,
        );


    if (stars >= 20) {
      await saveAchievement(
        id: "star_collector",
      );
    }
  }


  //==================================================
  // المهام اليومية
  //==================================================

  static Future<void> saveDailyMission({
    required String missionId,
    required int progress,
  }) async {

    await PuzzleProgressManager.saveDailyMission(
      missionId,
      progress,
    );
  }


  static Future<int> getDailyMissionProgress({
    required String missionId,
  }) async {

    return await PuzzleProgressManager
        .getDailyMissionProgress(
      missionId,
    );
  }


  static Future<void> completeDailyMission({
    required String missionId,
  }) async {

    await PuzzleProgressManager.completeDailyMission(
      missionId,
    );
  }


  //==================================================
  // الإحصائيات
  //==================================================

  static Future<void> updateStatistics({
    required String worldId,
    required int moves,
    required int seconds,
  }) async {

    await PuzzleProgressManager.updatePuzzleStatistics(
      worldId: worldId,
      moves: moves,
      seconds: seconds,
    );
  }


  static Future<Map<String, dynamic>>
  getPlayerStatistics() async {

    return await PuzzleProgressManager
        .getPuzzleStatistics();
  }


  //==================================================
  // بداية المستوى
  //==================================================

  static Future<void> onLevelStarted({
    required String worldId,
    required int level,
  }) async {

    await saveLastPlayed(
      worldId: worldId,
      levelNumber: level,
    );


    await PuzzleProgressManager.sendAnalytics(
      "level_started",
      {
        "world": worldId,
        "level": level,
      },
    );
  }


  //==================================================
  // نهاية المستوى
  //==================================================

  static Future<void> onLevelFinished({
    required String worldId,
    required int level,
    required int stars,
    required int moves,
    required int seconds,
  }) async {


    await finishLevel(
      worldId: worldId,
      levelNumber: level,
      stars: stars,
      difficulty: level,
    );


    await updateStatistics(
      worldId: worldId,
      moves: moves,
      seconds: seconds,
    );


    await checkAchievements(
      worldId: worldId,
    );


    await PuzzleProgressManager.sendAnalytics(
      "level_finished",
      {
        "world": worldId,
        "level": level,
        "stars": stars,
        "moves": moves,
        "time": seconds,
      },
    );
  }

  //==================================================
  // الخبرة ومستوى اللاعب
  //==================================================

  static Future<void> addExperience(
    int amount,
  ) async {

    await PuzzleProgressManager.addExperience(
      amount,
    );
  }


  static Future<int> getExperience() async {

    return await PuzzleProgressManager
        .getExperience();
  }


  static Future<int> getPlayerLevel() async {

    final xp =
        await getExperience();

    return (xp ~/ 100) + 1;
  }


  //==================================================
  // فتح جميع المراحل
  //==================================================

  static Future<void> unlockAllLevels({
    required String worldId,
  }) async {

    final levels =
        await getLevels(
          worldId,
        );


    for (final level in levels) {

      await PuzzleProgressManager.unlockLevel(
        "${worldId}_${level.id}",
      );
    }
  }


  //==================================================
  // إنهاء الملف
  //==================================================

}