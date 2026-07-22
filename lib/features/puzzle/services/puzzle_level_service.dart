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


    final levels =

    await getLevels(worldId);



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



    final levels =

    await getLevels(worldId);




    if(levelNumber <= 0 ||

        levelNumber > levels.length){


      return null;


    }




    return levels[levelNumber - 1];


  }


  //=========================================
  // التحقق من وجود المرحلة
  //=========================================


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






  //=========================================
  // هل المرحلة مفتوحة
  //=========================================


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
  // فتح شاشة المراحل
  //=========================================


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







  //=========================================
  // فتح مرحلة اللعب
  //=========================================


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
  //=========================================
  // إنهاء المرحلة
  //=========================================


  static Future<void> finishLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

    required int difficulty,

  }) async {



    final levelKey =

        "${worldId}_level_$levelNumber";





    // حفظ إكمال المرحلة

    await PuzzleProgressManager.completeLevel(

      levelKey,

    );






    // حفظ نجوم المرحلة

    await PuzzleProgressManager.saveLevelStars(

      levelKey,

      stars,

    );






    // إضافة النجوم للمجموع العام

    await PuzzleProgressManager.addStars(

      stars,

    );






    // فتح المرحلة التالية

    await unlockNextLevel(

      worldId: worldId,

      currentLevel: levelNumber,

    );





    // حفظ آخر مرحلة لعب

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



    final nextLevel = currentLevel + 1;





    final levels =

    await getLevels(

      worldId,

    );





    if(nextLevel > levels.length){


      return;


    }







    final key =

        "${worldId}_level_$nextLevel";






    await PuzzleProgressManager.unlockLevel(

      key,

    );


  }







  //=========================================
  // هل العالم مكتمل
  //=========================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );






    for(final level in levels){



      final key =

          "${worldId}_${level.id}";





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



    final levels =

    await getLevels(

      worldId,

    );




    int total = 0;





    for(final level in levels){



      final key =

          "${worldId}_${level.id}";





      total +=

      await PuzzleProgressManager.getLevelStars(

        key,

      );



    }





    return total;


  }


  //=========================================
  // إعادة ضبط تقدم عالم
  //=========================================


  static Future<void> resetWorld(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      final key =

          "${worldId}_${level.id}";





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