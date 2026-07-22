import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';



class PuzzleProgressManager {



  // =========================
  // Keys
  // =========================


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


  static const String claimedRewardsKey =
      "puzzle_claimed_rewards";



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



    final data =
    prefs.getString(progressKey);



    if(data == null){

      return null;

    }



    return jsonDecode(data);


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
  // ⭐ نظام النجوم
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




  static Future<void> removeStars(
      int amount,
      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(starsKey) ?? 0;



    final result = current - amount;



    await prefs.setInt(

      starsKey,

      result < 0 ? 0 : result,

    );


  }





  // =========================
  // 🪙 نظام العملات
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





  static Future<void> removeCoins(
      int amount,
      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(coinsKey) ?? 0;



    final result = current - amount;



    await prefs.setInt(

      coinsKey,

      result < 0 ? 0 : result,

    );


  }


  // =========================
  // 💡 نظام التلميحات
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
  // 🏆 مكافآت الفوز
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



    // المرحلة الأولى مفتوحة دائما

    if(levelId == "level_1"){

      return true;

    }



    return levels.contains(levelId);


  }





  // فتح المرحلة التالية

  static Future<void> unlockNextLevel(
      String currentLevelId,
      ) async {


    final current =
        int.tryParse(
          currentLevelId.replaceAll(
            "level_",
            "",
          ),
        ) ?? 1;



    if(current >= 30){

      return;

    }



    await unlockLevel(

      "level_${current + 1}",

    );


  }





  // =========================
  // 🧹 إعادة ضبط كل البيانات
  // =========================


  static Future<void> resetAll() async {


    final prefs =
    await SharedPreferences.getInstance();



    await prefs.clear();


  }


}