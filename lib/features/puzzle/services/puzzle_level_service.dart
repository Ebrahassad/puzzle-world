import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';
import '../managers/star_manager.dart';

import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_world_service.dart';

import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_home_screen.dart';


class PuzzleLevelService {


  const PuzzleLevelService._();





  static Future<List<PuzzleLevelModel>>

  getLevels(

      String worldId,

      ) async {



    return PuzzleLevelData.getLevels(

      worldId,

    );


  }








  static Future<int>

  getLevelCount(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    return levels.length;


  }








  static Future<PuzzleLevelModel?>

  getLevel(

      String worldId,

      int levelNumber,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    final index =

    levelNumber - 1;





    if(index < 0 ||

        index >= levels.length){



      return null;



    }





    return levels[index];



  }








  static Future<bool>

  levelExists(

      String worldId,

      int levelNumber,

      ) async {



    final level =

    await getLevel(

      worldId,

      levelNumber,

    );



    return level != null;


  }









  static Future<int>

  getTotalStars() async {



    return PuzzleProgressManager

        .getTotalStars();



  }









  static Future<bool>

  isLevelUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    final stars =

    await getTotalStars();





    return stars >=

        level.requiredStars;



  }









  static Future<bool>

  canPlayLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    return isLevelUnlocked(

      worldId: worldId,

      level: level,

    );


  }









  static Future<List<PuzzleLevelModel>>

  getUnlockedLevels(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    final result =

    <PuzzleLevelModel>[];



    for(final level in levels){



      final unlocked =

      await isLevelUnlocked(

        worldId: worldId,

        level: level,

      );





      if(unlocked){

        result.add(level);

      }



    }



    return result;


  }









  static Future<int>

  getCompletedCount(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    int count = 0;





    for(final level in levels){



      final id =

      "${worldId}_${level.id}";





      final completed =

      await PuzzleProgressManager

          .isCompleted(

        id,

      );





      if(completed){

        count++;

      }



    }





    return count;



  }









  static Future<double>

  getProgress(

      String worldId,

      ) async {



    final total =

    await getLevelCount(

      worldId,

    );





    if(total == 0){

      return 0;

    }





    final completed =

    await getCompletedCount(

      worldId,

    );





    return completed / total;



  }









  static Future<void>

  openLevel(

      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {



    final allowed =

    await canPlayLevel(

      worldId: world.id,

      level: level,

    );





    if(!allowed){

      return;

    }





    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleGameScreen(

              puzzle: world,

              level: level,

            ),

      ),

    );



  }









  static Future<void>

  openWorldLevels(

      BuildContext context, {

        required PuzzleModel world,

      }) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleLevelScreen(

              puzzle: world,

            ),

      ),

    );


  }









  static Future<void>

  backToPuzzleHome(

      BuildContext context,

      ) async {



    await Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleHomeScreen(),

      ),

          (route) => false,

    );


  }

}


  static Future<void>

  completeLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final levelKey =

    "${worldId}_level_$levelNumber";





    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelKey,

    );





    if(completed){

      return;

    }







    await PuzzleProgressManager

        .completeLevel(

      levelKey,

    );







    await PuzzleProgressManager

        .addStars(

      stars,

    );







    await StarManager

        .addStars(

      stars,

    );







    await unlockNextLevel(

      worldId: worldId,

      currentLevel: levelNumber,

    );


  }









  static Future<void>

  unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final nextLevel =

    currentLevel + 1;





    final levels =

    await getLevels(

      worldId,

    );





    if(nextLevel > levels.length){

      return;

    }







    final key =

    "${worldId}_level_$nextLevel";







    await PuzzleProgressManager

        .unlockLevel(

      key,

    );


  }









  static Future<bool>

  isCompleted({

    required String worldId,

    required int levelNumber,

  }) async {



    final key =

    "${worldId}_level_$levelNumber";





    return PuzzleProgressManager

        .isCompleted(

      key,

    );

  }









  static Future<int>

  getLevelStars({

    required String worldId,

    required int levelNumber,

  }) async {



    final key =

    "${worldId}_level_${levelNumber}_stars";





    return PuzzleProgressManager

        .getLevelStars(

      key,

    );

  }









  static Future<void>

  saveLevelStars({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final key =

    "${worldId}_level_${levelNumber}_stars";





    final oldStars =

    await PuzzleProgressManager

        .getLevelStars(

      key,

    );





    if(stars > oldStars){



      await PuzzleProgressManager

          .saveLevelStars(

        key,

        stars,

      );



    }


  }









  static Future<void>

  claimLevelReward({

    required String worldId,

    required int levelNumber,

    required int difficulty,

  }) async {



    final rewardKey =

    "${worldId}_level_$levelNumber";





    final claimed =

    await PuzzleProgressManager

        .isRewardClaimed(

      rewardKey,

    );





    if(claimed){

      return;

    }







    await RewardManager

        .completePuzzle(

      difficulty: difficulty,

    );







    await PuzzleProgressManager

        .markRewardClaimed(

      rewardKey,

    );


  }









  static Future<void>

  finishLevel({

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









  static Future<bool>

  isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      final completed =

      await isCompleted(

        worldId: worldId,

        levelNumber:

        int.parse(

          level.id

              .replaceAll(

            "level_",

            "",

          ),

        ),

      );





      if(!completed){

        return false;

      }



    }





    return true;


  }









  static Future<int>

  getWorldStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    int stars = 0;





    for(final level in levels){



      final number =

      int.parse(

        level.id

            .replaceAll(

          "level_",

          "",

        ),

      );





      stars += await getLevelStars(

        worldId: worldId,

        levelNumber: number,

      );



    }





    return stars;


  }

  static Future<void>

  completeLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final levelKey =

    "${worldId}_level_$levelNumber";





    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelKey,

    );





    if(completed){

      return;

    }







    await PuzzleProgressManager

        .completeLevel(

      levelKey,

    );







    await PuzzleProgressManager

        .addStars(

      stars,

    );







    await StarManager

        .addStars(

      stars,

    );







    await unlockNextLevel(

      worldId: worldId,

      currentLevel: levelNumber,

    );


  }









  static Future<void>

  unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final nextLevel =

    currentLevel + 1;





    final levels =

    await getLevels(

      worldId,

    );





    if(nextLevel > levels.length){

      return;

    }







    final key =

    "${worldId}_level_$nextLevel";







    await PuzzleProgressManager

        .unlockLevel(

      key,

    );


  }









  static Future<bool>

  isCompleted({

    required String worldId,

    required int levelNumber,

  }) async {



    final key =

    "${worldId}_level_$levelNumber";





    return PuzzleProgressManager

        .isCompleted(

      key,

    );

  }









  static Future<int>

  getLevelStars({

    required String worldId,

    required int levelNumber,

  }) async {



    final key =

    "${worldId}_level_${levelNumber}_stars";





    return PuzzleProgressManager

        .getLevelStars(

      key,

    );

  }









  static Future<void>

  saveLevelStars({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final key =

    "${worldId}_level_${levelNumber}_stars";





    final oldStars =

    await PuzzleProgressManager

        .getLevelStars(

      key,

    );





    if(stars > oldStars){



      await PuzzleProgressManager

          .saveLevelStars(

        key,

        stars,

      );



    }


  }









  static Future<void>

  claimLevelReward({

    required String worldId,

    required int levelNumber,

    required int difficulty,

  }) async {



    final rewardKey =

    "${worldId}_level_$levelNumber";





    final claimed =

    await PuzzleProgressManager

        .isRewardClaimed(

      rewardKey,

    );





    if(claimed){

      return;

    }







    await RewardManager

        .completePuzzle(

      difficulty: difficulty,

    );







    await PuzzleProgressManager

        .markRewardClaimed(

      rewardKey,

    );


  }









  static Future<void>

  finishLevel({

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









  static Future<bool>

  isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      final completed =

      await isCompleted(

        worldId: worldId,

        levelNumber:

        int.parse(

          level.id

              .replaceAll(

            "level_",

            "",

          ),

        ),

      );





      if(!completed){

        return false;

      }



    }





    return true;


  }









  static Future<int>

  getWorldStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    int stars = 0;





    for(final level in levels){



      final number =

      int.parse(

        level.id

            .replaceAll(

          "level_",

          "",

        ),

      );





      stars += await getLevelStars(

        worldId: worldId,

        levelNumber: number,

      );



    }





    return stars;


  }


  static Future<Map<String, dynamic>>

  getWorldStatistics(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    int completed = 0;

    int totalStars = 0;

    int bestMoves = 0;

    int bestTime = 0;





    for(final level in levels){



      final number =

      int.parse(

        level.id.replaceAll(

          "level_",

          "",

        ),

      );





      final done =

      await isCompleted(

        worldId: worldId,

        levelNumber: number,

      );





      if(done){

        completed++;

      }





      totalStars +=

      await getLevelStars(

        worldId: worldId,

        levelNumber: number,

      );



    }







    return {



      "worldId": worldId,


      "totalLevels": levels.length,


      "completedLevels": completed,


      "stars": totalStars,


      "bestMoves": bestMoves,


      "bestTime": bestTime,



    };


  }









  static Future<void>

  saveAchievement({

    required String id,

  }) async {



    await PuzzleProgressManager

        .saveAchievement(

      id,

    );


  }









  static Future<bool>

  hasAchievement({

    required String id,

  }) async {



    return PuzzleProgressManager

        .hasAchievement(

      id,

    );


  }









  static Future<void>

  checkAchievements({

    required String worldId,

  }) async {



    final completed =

    await getCompletedCount(

      worldId,

    );





    if(completed >= 5){



      await saveAchievement(

        id: "puzzle_master",

      );



    }





    final stars =

    await getWorldStars(

      worldId,

    );





    if(stars >= 20){



      await saveAchievement(

        id: "star_collector",

      );



    }


  }









  static Future<void>

  saveDailyMission({

    required String missionId,

    required int progress,

  }) async {



    await PuzzleProgressManager

        .saveDailyMission(

      missionId,

      progress,

    );


  }









  static Future<int>

  getDailyMissionProgress({

    required String missionId,

  }) async {



    return PuzzleProgressManager

        .getDailyMissionProgress(

      missionId,

    );


  }









  static Future<void>

  completeDailyMission({

    required String missionId,

  }) async {



    await PuzzleProgressManager

        .completeDailyMission(

      missionId,

    );


  }









  static Future<void>

  updateStatistics({

    required String worldId,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .updatePuzzleStatistics(

      worldId: worldId,

      moves: moves,

      seconds: seconds,

    );


  }









  static Future<Map<String,dynamic>>

  getPlayerStatistics() async {



    return PuzzleProgressManager

        .getPuzzleStatistics();


  }









  static Future<void>

  saveCloudBackup() async {



    await PuzzleProgressManager

        .prepareCloudBackup();


  }









  static Future<void>

  restoreCloudBackup() async {



    await PuzzleProgressManager

        .restoreCloudBackup();


  }









  static Future<void>

  sendAnalytics({

    required String event,

    Map<String,dynamic>? data,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      event,

      data,

    );


  }









  static Future<void>

  onLevelStarted({

    required String worldId,

    required int level,

  }) async {



    await saveLastPlayed(

      worldId: worldId,

      level: level,

    );





    await sendAnalytics(

      event: "level_started",

      data: {



        "world": worldId,


        "level": level,



      },

    );


  }









  static Future<void>

  onLevelFinished({

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





    await sendAnalytics(

      event: "level_finished",

      data: {



        "world": worldId,


        "level": level,


        "stars": stars,


        "moves": moves,


        "time": seconds,



      },

    );


  }



  static Future<void>

  addExperience({

    required int amount,

  }) async {



    await PuzzleProgressManager

        .addExperience(

      amount,

    );


  }









  static Future<int>

  getExperience() async {



    return PuzzleProgressManager

        .getExperience();


  }









  static Future<int>

  getPlayerLevel() async {



    final xp =

    await getExperience();





    return

    (xp ~/ 100) + 1;


  }









  static Future<void>

  addWeeklyChallengeProgress({

    required String challengeId,

    required int amount,

  }) async {



    await PuzzleProgressManager

        .addWeeklyChallengeProgress(

      challengeId,

      amount,

    );


  }









  static Future<int>

  getWeeklyChallengeProgress({

    required String challengeId,

  }) async {



    return PuzzleProgressManager

        .getWeeklyChallengeProgress(

      challengeId,

    );


  }









  static Future<bool>

  isSeasonActive() async {



    return PuzzleProgressManager

        .isSeasonActive();


  }









  static Future<void>

  saveSeasonProgress({

    required String seasonId,

    required int points,

  }) async {



    await PuzzleProgressManager

        .saveSeasonProgress(

      seasonId,

      points,

    );


  }









  static Future<int>

  getSeasonPoints({

    required String seasonId,

  }) async {



    return PuzzleProgressManager

        .getSeasonPoints(

      seasonId,

    );


  }









  static Future<void>

  claimSpecialReward({

    required String rewardId,

  }) async {



    await PuzzleProgressManager

        .claimSpecialReward(

      rewardId,

    );


  }









  static Future<bool>

  isRewardClaimed({

    required String rewardId,

  }) async {



    return PuzzleProgressManager

        .isSpecialRewardClaimed(

      rewardId,

    );


  }









  static Future<void>

  saveLeaderboardScore({

    required String playerId,

    required int score,

  }) async {



    await PuzzleProgressManager

        .saveLeaderboardScore(

      playerId,

      score,

    );


  }









  static Future<int>

  getLeaderboardScore({

    required String playerId,

  }) async {



    return PuzzleProgressManager

        .getLeaderboardScore(

      playerId,

    );


  }









  static Future<void>

  addVipPoints({

    required int points,

  }) async {



    await PuzzleProgressManager

        .addVipPoints(

      points,

    );


  }









  static Future<int>

  getVipPoints() async {



    return PuzzleProgressManager

        .getVipPoints();


  }









  static Future<void>

  purchaseLevel({

    required String worldId,

    required int level,

    required int cost,

  }) async {



    final coins =

    await RewardManager.getCoins();





    if(coins < cost){

      return;

    }







    await RewardManager

        .removeCoins(

      cost,

    );







    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_level_$level",

    );


  }









  static Future<void>

  unlockAllLevels({

    required String worldId,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      await PuzzleProgressManager

          .unlockLevel(

        "${worldId}_${level.id}",

      );



    }


  }









  static Future<void>

  resetWorldProgress({

    required String worldId,

  }) async {



    await PuzzleProgressManager

        .resetWorld(

      worldId,

    );


  }









  static Future<void>

  resetAllPuzzleData() async {



    await PuzzleProgressManager

        .resetPuzzleData();


  }









  static Future<Map<String,dynamic>>

  exportPuzzleData() async {



    return PuzzleProgressManager

        .exportData();


  }









  static Future<void>

  importPuzzleData(

      Map<String,dynamic> data,

      ) async {



    await PuzzleProgressManager

        .importData(

      data,

    );


  }

}