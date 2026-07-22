import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';


class PuzzleProgressManager {


  static const String progressKey =
      "puzzle_current_progress";


  static const String starsKey =
      "puzzle_stars";


  static const String coinsKey =
      "puzzle_coins";


  static const String gemsKey =
      "puzzle_gems";


  static const String hintsKey =
      "puzzle_hints";


  static const String completedLevelsKey =
      "puzzle_completed_levels";


  static const String unlockedLevelsKey =
      "puzzle_unlocked_levels";


  static const String lastGameKey =
      "puzzle_last_game";


  static const String lastSessionKey =
      "puzzle_last_session";


  static const String claimedRewardsKey =
      "puzzle_claimed_rewards";


  static const String movesKey =
      "puzzle_total_moves";


  static const String completedCountKey =
      "puzzle_completed_count";


  static const String bestTimeKey =
      "puzzle_best_time";





  // =========================
  // حفظ تقدم البازل
  // =========================


  static Future<void> saveProgress({

    required String puzzleId,

    required String levelId,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {


    final prefs =
    await SharedPreferences.getInstance();



    final data = {


      "puzzleId": puzzleId,


      "levelId": levelId,


      "moves": moves,


      "seconds": seconds,


      "pieces": pieces.map((piece){


        return {


          "id": piece.id,


          "row": piece.row,


          "column": piece.column,


          "x": piece.position.dx,


          "y": piece.position.dy,


          "placed": piece.placed,


        };


      }).toList(),


    };



    await prefs.setString(

      progressKey,

      jsonEncode(data),

    );


  }






  // =========================
  // تحميل التقدم
  // =========================


  static Future<Map<String,dynamic>?>

  loadProgress() async {


    final prefs =
    await SharedPreferences.getInstance();


    final value =
        prefs.getString(progressKey);



    if(value == null){

      return null;

    }



    return Map<String,dynamic>.from(

      jsonDecode(value),

    );


  }






  static Future<void> clearProgress() async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.remove(progressKey);


  }






  // =========================
  // ⭐ النجوم
  // =========================


  static Future<void> addStars(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(starsKey) ?? 0;



    await prefs.setInt(

      starsKey,

      current + amount,

    );


  }





  static Future<int> getStars() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(starsKey) ?? 0;


  }





  static Future<int> getTotalStars() async {


    return getStars();


  }





  static Future<void> saveStars(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.setInt(

      starsKey,

      amount,

    );


  }
  // =========================
  // 🪙 العملات
  // =========================


  static Future<void> addCoins(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(coinsKey) ?? 0;



    await prefs.setInt(

      coinsKey,

      current + amount,

    );


  }





  static Future<int> getCoins() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(coinsKey) ?? 0;


  }





  // =========================
  // 💎 الجواهر
  // =========================


  static Future<void> addGems(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(gemsKey) ?? 0;



    await prefs.setInt(

      gemsKey,

      current + amount,

    );


  }





  static Future<int> getGems() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(gemsKey) ?? 0;


  }





  // =========================
  // 💡 التلميحات
  // =========================


  static Future<void> addHints(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(hintsKey) ?? 0;



    int result = current + amount;


    if(result < 0){

      result = 0;

    }



    await prefs.setInt(

      hintsKey,

      result,

    );


  }





  static Future<int> getHints() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(hintsKey) ?? 0;


  }





  static Future<bool> useHint() async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(hintsKey) ?? 0;



    if(current <= 0){

      return false;

    }



    await prefs.setInt(

      hintsKey,

      current - 1,

    );


    return true;


  }





  // =========================
  // 🏆 المراحل المكتملة
  // =========================


  static Future<void> completeLevel(

      String levelId,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelId)){


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


    final prefs =
    await SharedPreferences.getInstance();


    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    return levels.contains(levelId);


  }





  static Future<int> getCompletedPuzzleCount() async {


    final prefs =
    await SharedPreferences.getInstance();


    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    return levels.length;


  }





  // =========================
  // 🔓 فتح المراحل
  // =========================


  static Future<void> unlockLevel(

      String levelId,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelId)){


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


    final prefs =
    await SharedPreferences.getInstance();


    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    if(levelId.endsWith("_level_1")){

      return true;

    }



    return levels.contains(levelId);


  }





  static Future<void> unlockNextLevel(

      String currentLevelId,

      ) async {


    final data =
        currentLevelId.split("_level_");



    if(data.length != 2){

      return;

    }



    final world = data[0];


    final current =
        int.tryParse(data[1]) ?? 1;



    await unlockLevel(

      "${world}_level_${current + 1}",

    );


  }

  // =========================
  // 🎮 آخر لعبة
  // =========================


  static Future<void> saveLastGame(

      String value,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.setString(

      lastGameKey,

      value,

    );


  }





  static Future<String?> getLastGame() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getString(

      lastGameKey,

    );


  }





  // =========================
  // ⏱ آخر جلسة
  // =========================


  static Future<void> saveLastSession(

      DateTime time,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.setString(

      lastSessionKey,

      time.toIso8601String(),

    );


  }





  static Future<DateTime?> getLastSession() async {


    final prefs =
    await SharedPreferences.getInstance();


    final value =
        prefs.getString(lastSessionKey);



    if(value == null){

      return null;

    }



    return DateTime.tryParse(value);


  }





  // =========================
  // 🎁 المكافآت
  // =========================


  static Future<bool> isRewardClaimed(

      String levelId,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final rewards =

    prefs.getStringList(

      claimedRewardsKey,

    ) ?? [];



    return rewards.contains(levelId);


  }





  static Future<void> markRewardClaimed(

      String levelId,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final rewards =

    prefs.getStringList(

      claimedRewardsKey,

    ) ?? [];



    if(!rewards.contains(levelId)){


      rewards.add(levelId);


    }



    await prefs.setStringList(

      claimedRewardsKey,

      rewards,

    );


  }





  // =========================
  // 📊 الإحصائيات
  // =========================


  static Future<void> addGamePlayed() async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt("puzzle_games_played") ?? 0;



    await prefs.setInt(

      "puzzle_games_played",

      current + 1,

    );


  }





  static Future<int> getGamesPlayed() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(

      "puzzle_games_played",

    ) ?? 0;


  }





  static Future<void> addCompletedPuzzle({

    required int stars,

    required int moves,

    required int seconds,

  }) async {


    final prefs =
    await SharedPreferences.getInstance();



    final completed =
        prefs.getInt(completedCountKey) ?? 0;



    await prefs.setInt(

      completedCountKey,

      completed + 1,

    );



    final totalMoves =
        prefs.getInt(movesKey) ?? 0;



    await prefs.setInt(

      movesKey,

      totalMoves + moves,

    );



    final oldBest =
        prefs.getInt(bestTimeKey);



    if(oldBest == null || seconds < oldBest){


      await prefs.setInt(

        bestTimeKey,

        seconds,

      );


    }



  }





  static Future<int> getTotalMoves() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(movesKey) ?? 0;


  }





  static Future<int> getBestTime() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(bestTimeKey) ?? 0;


  }





  static Future<void> resetStatistics() async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.remove(

      movesKey,

    );


    await prefs.remove(

      bestTimeKey,

    );


    await prefs.remove(

      completedCountKey,

    );


  }





  // =========================
  // 🔄 إعادة كل البيانات
  // =========================


  static Future<void> resetAll() async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.remove(progressKey);

    await prefs.remove(starsKey);

    await prefs.remove(coinsKey);

    await prefs.remove(gemsKey);

    await prefs.remove(hintsKey);

    await prefs.remove(completedLevelsKey);

    await prefs.remove(unlockedLevelsKey);

    await prefs.remove(lastGameKey);

    await prefs.remove(lastSessionKey);

    await prefs.remove(claimedRewardsKey);

    await prefs.remove(movesKey);

    await prefs.remove(completedCountKey);

    await prefs.remove(bestTimeKey);


  }


}