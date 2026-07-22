import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';

import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_level_screen.dart';



class PuzzleLevelService {


  const PuzzleLevelService._();



  //==================================================
  // جلب مراحل العالم
  //==================================================


  static Future<List<PuzzleLevelModel>> getLevels(

      String worldId,

      ) async {


    return PuzzleLevelData.getLevels(

      worldId,

    );


  }






  //==================================================
  // عدد المراحل
  //==================================================


  static Future<int> getLevelCount(

      String worldId,

      ) async {


    final levels =

    await getLevels(worldId);



    return levels.length;


  }






  //==================================================
  // جلب مرحلة محددة
  //==================================================


  static Future<PuzzleLevelModel?>

  getLevel({

    required String worldId,

    required int levelNumber,

  }) async {



    final levels =

    await getLevels(worldId);




    if(levelNumber <= 0 ||

        levelNumber > levels.length){


      return null;


    }





    return levels[levelNumber - 1];


  }






  //==================================================
  // هل المرحلة موجودة
  //==================================================


  static Future<bool> levelExists({

    required String worldId,

    required int levelNumber,

  }) async {


    final level =

    await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );



    return level != null;


  }






  //==================================================
  // حالة فتح المرحلة
  //==================================================


  static Future<bool> isLevelUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    return PuzzleProgressManager

        .isLevelUnlocked(

      "${worldId}_${level.id}",

    );


  }






  //==================================================
  // هل يمكن لعب المرحلة
  //==================================================


  static Future<bool> canPlayLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    return await isLevelUnlocked(

      worldId: worldId,

      level: level,

    );


  }






  //==================================================
  // فتح شاشة المراحل
  //==================================================


  static Future<void> openWorldLevels(

      BuildContext context,

      PuzzleModel puzzle,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleLevelScreen(

              puzzle: puzzle,

            ),

      ),

    );


  }






  //==================================================
  // فتح اللعبة
  //==================================================


  static Future<void> openLevel(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    final allowed =

    await canPlayLevel(

      worldId: puzzle.id,

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

              puzzle: puzzle,

              level: level,

            ),

      ),

    );


  }


  //==================================================
  // العودة للرئيسية
  //==================================================


  static Future<void> backToPuzzleHome(

      BuildContext context,

      ) async {


    Navigator.popUntil(

      context,

      (route) => route.isFirst,

    );


  }






  //==================================================
  // عدد النجوم الكلي
  //==================================================


  static Future<int> getTotalStars() async {


    return await PuzzleProgressManager

        .getTotalStars();


  }






  //==================================================
  // المراحل المفتوحة
  //==================================================


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






  //==================================================
  // عدد المراحل المكتملة
  //==================================================


  static Future<int> getCompletedCount(

      String worldId,

      ) async {


    final levels =

    await getLevels(

      worldId,

    );



    int count = 0;



    for(final level in levels){



      final completed =

      await PuzzleProgressManager

          .isCompleted(

        "${worldId}_${level.id}",

      );



      if(completed){

        count++;

      }


    }



    return count;


  }






  //==================================================
  // نسبة تقدم العالم
  //==================================================


  static Future<double> getProgress(

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






  //==================================================
  // هل العالم مكتمل
  //==================================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    for(final level in levels){



      final done =

      await PuzzleProgressManager

          .isCompleted(

        "${worldId}_${level.id}",

      );



      if(!done){

        return false;

      }


    }



    return true;


  }

  //==================================================
  // نجوم العالم
  //==================================================


  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    int stars = 0;



    for(final level in levels){



      stars +=

      await PuzzleProgressManager

          .getLevelStars(

        "${worldId}_${level.id}",

      );



    }



    return stars;


  }








  //==================================================
  // حفظ نجوم المرحلة
  //==================================================


  static Future<void> saveLevelStars({

    required String worldId,

    required String levelId,

    required int stars,

  }) async {



    await PuzzleProgressManager

        .saveLevelStars(

      "${worldId}_$levelId",

      stars,

    );


  }








  //==================================================
  // نجوم مرحلة معينة
  //==================================================


  static Future<int> getLevelStars({

    required String worldId,

    required String levelId,

  }) async {



    return await PuzzleProgressManager

        .getLevelStars(

      "${worldId}_$levelId",

    );


  }








  //==================================================
  // إنهاء المرحلة من مكان واحد
  //==================================================


  static Future<void> finishLevel({

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

        .saveLevelStars(

      levelKey,

      stars,

    );







    await PuzzleProgressManager

        .addStars(

      stars,

    );







    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      levelNumber,

    );


  }







  //==================================================
  // فتح مرحلة يدوياً
  //==================================================


  static Future<void> unlockLevel({

    required String worldId,

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_$levelId",

    );


  }








}
