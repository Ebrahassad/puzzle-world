import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';


class PuzzleProgressManager {

  PuzzleProgressManager._();


  //==================================================
  // Keys
  //==================================================

  static const String progressKey =
      "puzzle_current_progress";

  static const String starsKey =
      "puzzle_total_stars";

  static const String coinsKey =
      "puzzle_coins";

  static const String gemsKey =
      "puzzle_gems";

  static const String hintsKey =
      "puzzle_hints";

  static const String lastWorldKey =
      "puzzle_last_world";

  static const String lastLevelKey =
      "puzzle_last_level";


  static const String completedLevelsKey =
      "puzzle_completed_levels";
static const String claimedRewardsKey =
    "puzzle_claimed_rewards";

  static const String unlockedLevelsKey =
      "puzzle_unlocked_levels";

  static const String levelStarsKey =
      "puzzle_level_stars";


  static const String gamesPlayedKey =
      "puzzle_games_played";

  static const String totalMovesKey =
      "puzzle_total_moves";

  static const String bestTimeKey =
      "puzzle_best_time";


  static const String achievementsKey =
      "puzzle_achievements";


  static const String experienceKey =
      "puzzle_experience";


  static const String dailyMissionKey =
      "puzzle_daily_missions";


  //==================================================
  // Preferences
  //==================================================


  static Future<SharedPreferences> get _prefs async {

    return await SharedPreferences.getInstance();

  }



  //==================================================
  // حفظ حالة البازل الحالية
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





  //==================================================
  // قراءة حالة البازل
  //==================================================


  static Future<Map<String,dynamic>?>

  loadProgress() async {


    final prefs = await _prefs;


    final value =

    prefs.getString(progressKey);



    if(value == null){

      return null;

    }



    return Map<String,dynamic>.from(

      jsonDecode(value),

    );


  }





  //==================================================
  // حذف البازل المحفوظ
  //==================================================


  static Future<void>

  clearProgress() async {


    final prefs = await _prefs;


    await prefs.remove(

      progressKey,

    );


  }


  //==================================================
  // ⭐ نظام النجوم
  //==================================================


  static Future<int> getTotalStars() async {

    final prefs = await _prefs;

    return prefs.getInt(starsKey) ?? 0;

  }




  static Future<int> getStars() async {

    return getTotalStars();

  }




  static Future<void> addStars(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(starsKey) ?? 0;


    int value = current + amount;


    if(value < 0){

      value = 0;

    }


    await prefs.setInt(

      starsKey,

      value,

    );


  }





  static Future<void> saveStars(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      starsKey,

      value,

    );


  }





  //==================================================
  // 🪙 العملات
  //==================================================


  static Future<int> getCoins() async {


    final prefs = await _prefs;


    return prefs.getInt(coinsKey) ?? 0;


  }




  static Future<void> addCoins(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(coinsKey) ?? 0;


    int value = current + amount;


    if(value < 0){

      value = 0;

    }


    await prefs.setInt(

      coinsKey,

      value,

    );


  }





  static Future<void> saveCoins(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      coinsKey,

      value,

    );


  }





  //==================================================
  // 💎 الجواهر
  //==================================================


  static Future<int> getGems() async {


    final prefs = await _prefs;


    return prefs.getInt(gemsKey) ?? 0;


  }





  static Future<void> addGems(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(gemsKey) ?? 0;


    int value = current + amount;


    if(value < 0){

      value = 0;

    }


    await prefs.setInt(

      gemsKey,

      value,

    );


  }





  static Future<void> saveGems(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      gemsKey,

      value,

    );


  }





  //==================================================
  // 💡 التلميحات
  //==================================================


  static Future<int> getHints() async {


    final prefs = await _prefs;


    return prefs.getInt(hintsKey) ?? 0;


  }





  static Future<void> addHints(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(hintsKey) ?? 0;


    int value = current + amount;


    if(value < 0){

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


    if(current <= 0){

      return false;

    }


    await prefs.setInt(

      hintsKey,

      current - 1,

    );


    return true;


  }

  //==================================================
  // 🏆 إكمال المراحل
  //==================================================


  static Future<void> completeLevel(

      String levelKey,

      ) async {


    final prefs = await _prefs;


    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelKey)){


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

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];


    return levels.contains(levelKey);


  }





  static Future<int> getCompletedCount() async {


    final prefs = await _prefs;


    return

    (prefs.getStringList(

      completedLevelsKey,

    ) ?? []).length;


  }


//==================================================
// 🎁 المكافآت المستلمة
//==================================================

static Future<void> markRewardClaimed(
    String levelKey,
    ) async {

  final prefs = await _prefs;

  final list =
      prefs.getStringList(claimedRewardsKey) ?? [];


  if(!list.contains(levelKey)){

    list.add(levelKey);

    await prefs.setStringList(
      claimedRewardsKey,
      list,
    );

  }

}




static Future<bool> isRewardClaimed(
    String levelKey,
    ) async {

  final prefs = await _prefs;

  final list =
      prefs.getStringList(claimedRewardsKey) ?? [];


  return list.contains(levelKey);

}


  //==================================================
  // 🔓 فتح المراحل
  //==================================================


  static Future<void> unlockLevel(

      String levelKey,

      ) async {


    final prefs = await _prefs;


    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelKey)){


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


    final prefs = await _prefs;


    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    if(levelKey.contains("_level_1")){
  return true;
}

    return levels.contains(levelKey);


  }





  static Future<void> unlockNextLevel(

      String worldId,

      int currentLevel,

      ) async {


    final next = currentLevel + 1;


    await unlockLevel(

      "${worldId}_level_$next",

    );


  }



  //==================================================
  // ⭐ نجوم كل مرحلة
  //==================================================


  static Future<void> saveLevelStars(

      String levelKey,

      int stars,

      ) async {


    final prefs = await _prefs;


    final data = Map<String,dynamic>.from(

      jsonDecode(

        prefs.getString(levelStarsKey) ?? "{}",

      ),

    );



    final old = data[levelKey] ?? 0;



    if(stars > old){


      data[levelKey] = stars;


      await prefs.setString(

        levelStarsKey,

        jsonEncode(data),

      );


    }


  }





  static Future<int> getLevelStars(

      String levelKey,

      ) async {


    final prefs = await _prefs;


    final data = Map<String,dynamic>.from(

      jsonDecode(

        prefs.getString(levelStarsKey) ?? "{}",

      ),

    );


    return data[levelKey] ?? 0;


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





  static Future<Map<String,String>?>

  getLastPuzzle() async {


    final prefs = await _prefs;


    final world = prefs.getString(lastWorldKey);

    final level = prefs.getString(lastLevelKey);



    if(world == null || level == null){

      return null;

    }


    return {

      "worldId": world,

      "levelId": level,

    };


  }

  //==================================================
  // 📊 الإحصائيات
  //==================================================


  static Future<int> getGamesPlayed() async {

    final prefs = await _prefs;

    return prefs.getInt(gamesPlayedKey) ?? 0;

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



    if(best == 0 || seconds < best){


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

    prefs.getStringList(

      achievementsKey,

    ) ?? [];



    if(!list.contains(id)){


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

    prefs.getStringList(

      achievementsKey,

    ) ?? [];


    return list.contains(id);


  }





  //==================================================
  // ⭐ الخبرة XP
  //==================================================


  static Future<void> addExperience(

      int amount,

      ) async {


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
  // 💾 تصدير واستيراد البيانات
  //==================================================


  static Future<Map<String,dynamic>>

  exportData() async {


    final prefs = await _prefs;


    final result = <String,dynamic>{};


    for(final key in prefs.getKeys()){


      result[key] = prefs.get(key);


    }


    return result;


  }





  static Future<void> importData(

      Map<String,dynamic> data,

      ) async {


    final prefs = await _prefs;


    for(final item in data.entries){


      final value = item.value;


      if(value is int){


        await prefs.setInt(

          item.key,

          value,

        );


      }

      else if(value is String){


        await prefs.setString(

          item.key,

          value,

        );


      }

      else if(value is List<String>){


        await prefs.setStringList(

          item.key,

          value,

        );


      }


    }


  }


  //==================================================
  // حذف تقدم مرحلة واحدة
  //==================================================


  static Future<void> removeLevel(

      String levelKey,

      ) async {


    final prefs = await _prefs;



    // حذف من المراحل المكتملة

    final completed =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    completed.remove(levelKey);



    await prefs.setStringList(

      completedLevelsKey,

      completed,

    );





    // حذف من المراحل المفتوحة

    final unlocked =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    unlocked.remove(levelKey);



    await prefs.setStringList(

      unlockedLevelsKey,

      unlocked,

    );





    // حذف نجوم المرحلة

    final starsData =

    Map<String,dynamic>.from(

      jsonDecode(

        prefs.getString(levelStarsKey) ?? "{}",

      ),

    );



    starsData.remove(levelKey);



    await prefs.setString(

      levelStarsKey,

      jsonEncode(starsData),

    );


  }


//==================================================
// حذف إكمال مرحلة
//==================================================

static Future<void> removeCompletedLevel(

    String levelKey,

    ) async {


  final prefs = await _prefs;


  final levels =

  prefs.getStringList(

    completedLevelsKey,

  ) ?? [];



  levels.remove(levelKey);



  await prefs.setStringList(

    completedLevelsKey,

    levels,

  );


}





//==================================================
// حذف نجوم مرحلة
//==================================================

static Future<void> removeLevelStars(

    String levelKey,

    ) async {


  final prefs = await _prefs;



  final data = Map<String,dynamic>.from(

    jsonDecode(

      prefs.getString(levelStarsKey) ?? "{}",

    ),

  );



  data.remove(levelKey);



  await prefs.setString(

    levelStarsKey,

    jsonEncode(data),

  );


}


  //==================================================
  // 🧹 إعادة ضبط النظام
  //==================================================


  static Future<void> resetAll() async {

  final prefs = await _prefs;

  await prefs.remove(progressKey);

  await prefs.remove(completedLevelsKey);

  await prefs.remove(unlockedLevelsKey);

  await prefs.remove(levelStarsKey);

  await prefs.remove(starsKey);

  await prefs.remove(coinsKey);

  await prefs.remove(gemsKey);

  await prefs.remove(hintsKey);

}


}