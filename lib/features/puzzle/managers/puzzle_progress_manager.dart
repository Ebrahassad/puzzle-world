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


  static const String hintsKey =
      "puzzle_hints";


  static const String completedLevelsKey =
      "puzzle_completed_levels";


  static const String unlockedLevelsKey =
      "puzzle_unlocked_levels";





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









  // =========================
  // حذف التقدم الحالي
  // =========================


  static Future<void> clearProgress() async {


    final prefs =
    await SharedPreferences.getInstance();



    await prefs.remove(

      progressKey,

    );


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
  // 💡 التلميحات
  // =========================


  static Future<void> addHints(

      int amount,

      ) async {


    final prefs =
    await SharedPreferences.getInstance();



    final current =
        prefs.getInt(hintsKey) ?? 0;



    await prefs.setInt(

      hintsKey,

      current + amount,

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
  // 🏆 إكمال مرحلة
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









  // =========================
  // 🔓 فتح مرحلة
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









  // =========================
  // هل المرحلة مفتوحة
  // يدعم العوالم
  // مثال:
  // animals_level_1
  // cars_level_1
  // =========================


  static Future<bool> isUnlocked(

      String levelId,

      ) async {



    final prefs =
    await SharedPreferences.getInstance();



    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];




    // أول مرحلة في كل عالم مفتوحة

    if(levelId.endsWith("_level_1")){


      return true;


    }





    return levels.contains(levelId);


  }









  // =========================
  // فتح المرحلة التالية
  // =========================


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




    final next =

    "${world}_level_${current + 1}";




    await unlockLevel(

      next,

    );


  }









  // =========================
  // إعادة كل البيانات
  // =========================


  static Future<void> resetAll() async {



    final prefs =
    await SharedPreferences.getInstance();




    await prefs.remove(progressKey);


    await prefs.remove(starsKey);


    await prefs.remove(coinsKey);


    await prefs.remove(hintsKey);


    await prefs.remove(completedLevelsKey);


    await prefs.remove(unlockedLevelsKey);



  }



}