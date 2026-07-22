import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';

import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';



class PuzzleLevelService {


  const PuzzleLevelService._();




  //=========================================
  // 🔑 مفتاح المرحلة الموحد
  //=========================================


  static String levelKey(

      String worldId,

      int levelNumber,

      ){

    return "${worldId}_level_$levelNumber";

  }






  //=========================================
  // جلب كل مراحل العالم
  //=========================================


  static Future<List<PuzzleLevelModel>> getLevels(

      String worldId,

      ) async {


    return PuzzleLevelData.getLevels(

      worldId,

    );


  }






  //=========================================
  // عدد المراحل
  //=========================================


  static Future<int> getLevelCount(

      String worldId,

      ) async {


    final levels = await getLevels(

      worldId,

    );


    return levels.length;


  }






  //=========================================
  // جلب مرحلة معينة
  //=========================================


  static Future<PuzzleLevelModel?>

  getLevel({

    required String worldId,

    required int levelNumber,

  }) async {


    final levels = await getLevels(

      worldId,

    );



    for(final level in levels){


      if(level.levelNumber == levelNumber){


        return level;


      }


    }



    return null;


  }






  //=========================================
  // التحقق من وجود المرحلة
  //=========================================


  static Future<bool> levelExists({

    required String worldId,

    required int levelNumber,

  }) async {



    final level = await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );



    return level != null;


  }






  //=========================================
  // هل المرحلة مفتوحة
  //=========================================


  static Future<bool> isLevelUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.levelNumber == 1){

      return true;

    }





    return PuzzleProgressManager.isLevelUnlocked(

      levelKey(

        worldId,

        level.levelNumber,

      ),

    );


  }

  //=========================================
  // هل يمكن بدء المرحلة
  //=========================================


  static Future<bool> canPlayLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    return await isLevelUnlocked(

      worldId: worldId,

      level: level,

    );


  }






  //=========================================
  // فتح شاشة مراحل العالم
  //=========================================


  static Future<void> openWorldLevels(

      BuildContext context,

      PuzzleModel puzzle,

      ) async {


    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleLevelScreen(

          puzzle: puzzle,

        ),

      ),

    );


  }






  //=========================================
  // فتح لعبة مرحلة
  //=========================================


  static Future<void> openLevel(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    final allowed = await canPlayLevel(

      worldId: puzzle.id,

      level: level,

    );




    if(!allowed){

      return;

    }




    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleGameScreen(

          puzzle: puzzle,

          level: level,

        ),

      ),

    );


  }






  //=========================================
  // إنهاء المرحلة
  //=========================================


  static Future<void> finishLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final key = levelKey(

      worldId,

      levelNumber,

    );






    // حفظ الإكمال

    await PuzzleProgressManager.completeLevel(

      key,

    );






    // حفظ نجوم المرحلة

    await PuzzleProgressManager.saveLevelStars(

      key,

      stars,

    );






    // إضافة النجوم للمجموع

    await PuzzleProgressManager.addStars(

      stars,

    );






    // فتح المرحلة التالية

    await unlockNextLevel(

      worldId: worldId,

      currentLevel: levelNumber,

    );






    // حفظ آخر مرحلة

    await PuzzleProgressManager.saveLastPuzzle(

      worldId,

      "level_$levelNumber",

    );


  }






  //=========================================
  // فتح المرحلة التالية
  //=========================================


  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final next = currentLevel + 1;



    final exists = await levelExists(

      worldId: worldId,

      levelNumber: next,

    );



    if(!exists){

      return;

    }




    await PuzzleProgressManager.unlockLevel(

      levelKey(

        worldId,

        next,

      ),

    );


  }

  //=========================================
  // هل العالم مكتمل
  //=========================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );





    for(final level in levels){



      final key = levelKey(

        worldId,

        level.levelNumber,

      );





      final completed =

      await PuzzleProgressManager.isCompleted(

        key,

      );





      if(!completed){

        return false;

      }



    }





    return true;


  }







  //=========================================
  // نجوم العالم
  //=========================================


  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );





    int total = 0;





    for(final level in levels){



      total +=

      await PuzzleProgressManager.getLevelStars(

        levelKey(

          worldId,

          level.levelNumber,

        ),

      );



    }





    return total;


  }







  //=========================================
  // إعادة ضبط تقدم العالم
  //=========================================


  static Future<void> resetWorld(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );





    for(final level in levels){



      final key = levelKey(

        worldId,

        level.levelNumber,

      );





      await PuzzleProgressManager.removeLevel(

        key,

      );


    }


  }







  //=========================================
  // الحصول على المرحلة التالية
  //=========================================


  static Future<PuzzleLevelModel?>

  getNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    return await getLevel(

      worldId: worldId,

      levelNumber: currentLevel + 1,

    );


  }






}