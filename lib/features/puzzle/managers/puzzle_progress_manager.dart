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



  //==================================================
  // Preferences
  //==================================================


  static Future<SharedPreferences> get _prefs async {

    return await SharedPreferences.getInstance();

  }




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
  // قراءة اللعبة الحالية
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






  static Future<void>

  clearProgress() async {


    final prefs = await _prefs;


    await prefs.remove(

      progressKey,

    );


  }





  //==================================================
  // ⭐ النجوم
  //==================================================


  static Future<int>

  getTotalStars() async {


    final prefs = await _prefs;


    return prefs.getInt(starsKey) ?? 0;


  }






  static Future<int>

  getStars() async {


    return getTotalStars();


  }







  static Future<void>

  addStars(int amount) async {


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








  static Future<void>

  saveStars(int value) async {


    final prefs = await _prefs;


    await prefs.setInt(

      starsKey,

      value,

    );


  }





  //==================================================
  // 🪙 العملات
  //==================================================


  static Future<int>

  getCoins() async {


    final prefs = await _prefs;


    return prefs.getInt(coinsKey) ?? 0;


  }






  static Future<void>

  addCoins(int amount) async {


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







  static Future<void>

  saveCoins(int value) async {


    final prefs = await _prefs;


    await prefs.setInt(

      coinsKey,

      value,

    );


  }







  //==================================================
  // 💎 الجواهر
  //==================================================


  static Future<int>

  getGems() async {


    final prefs = await _prefs;


    return prefs.getInt(gemsKey) ?? 0;


  }






  static Future<void>

  addGems(int amount) async {


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






  static Future<void>

  saveGems(int value) async {


    final prefs = await _prefs;


    await prefs.setInt(

      gemsKey,

      value,

    );


  }







  //==================================================
  // 💡 التلميحات
  //==================================================


  static Future<int>

  getHints() async {


    final prefs = await _prefs;


    return prefs.getInt(hintsKey) ?? 0;


  }






  static Future<void>

  addHints(int amount) async {


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







  static Future<bool>

  useHint() async {


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



    // المرحلة الأولى مفتوحة دائماً

    if(levelKey.endsWith("_level_1")){

      return true;

    }



    return levels.contains(levelKey);


  }








  static Future<void> unlockNextLevel(

      String worldId,

      int currentLevel,

      ) async {



    final nextLevel = currentLevel + 1;



    final key =

    "${worldId}_level_$nextLevel";



    await unlockLevel(key);


  }








  //==================================================
  // ⭐ نجوم كل مرحلة
  //==================================================



  static Future<void> saveLevelStars(

      String levelKey,

      int stars,

      ) async {



    final prefs = await _prefs;



    final data =

    jsonDecode(

      prefs.getString(levelStarsKey) ?? "{}",

    );



    final oldStars =

    data[levelKey] ?? 0;



    if(stars > oldStars){


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



    final data =

    jsonDecode(

      prefs.getString(levelStarsKey) ?? "{}",

    );



    return data[levelKey] ?? 0;


  }







  //==================================================
  // 🎮 آخر لعبة
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



    final world =

    prefs.getString(lastWorldKey);



    final level =

    prefs.getString(lastLevelKey);



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
  // 🧹 إعادة ضبط النظام
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

    await prefs.remove(levelStarsKey);

    await prefs.remove(lastWorldKey);

    await prefs.remove(lastLevelKey);

    await prefs.remove(gamesPlayedKey);

    await prefs.remove(totalMovesKey);

    await prefs.remove(bestTimeKey);


  }