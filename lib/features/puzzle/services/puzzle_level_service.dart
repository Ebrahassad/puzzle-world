import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';

import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';


class PuzzleLevelService {

  const PuzzleLevelService._();



  //==================================================
  // جلب مراحل العالم
  //==================================================

  static Future<List<PuzzleLevelModel>> getLevels(
      String worldId,
      ) async {

    return PuzzleLevelData.getLevels(worldId);

  }





  //==================================================
  // عدد المراحل
  //==================================================

  static Future<int> getLevelCount(
      String worldId,
      ) async {

    final levels = await getLevels(worldId);

    return levels.length;

  }





  //==================================================
  // جلب مرحلة برقمها
  //==================================================

  static Future<PuzzleLevelModel?> getLevel({

    required String worldId,

    required int levelNumber,

  }) async {


    final levels = await getLevels(worldId);


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


    final level = await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );


    return level != null;


  }





  //==================================================
  // مفتاح المرحلة الموحد
  //==================================================

  static String levelKey({

    required String worldId,

    required int levelNumber,

  }) {

    return "${worldId}_level_$levelNumber";

  }





  //==================================================
  // هل المرحلة مفتوحة
  //==================================================

  static Future<bool> isLevelUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    if(level.levelNumber == 1){

      return true;

    }


    return PuzzleProgressManager.isLevelUnlocked(

      levelKey(
        worldId: worldId,
        levelNumber: level.levelNumber,
      ),

    );


  }





  //==================================================
  // هل يمكن اللعب
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

        builder: (_) => PuzzleLevelScreen(

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

  //==================================================
  // إنهاء المرحلة
  //==================================================

  static Future<void> finishLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final key = levelKey(

      worldId: worldId,

      levelNumber: levelNumber,

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







  //==================================================
  // فتح المرحلة التالية
  //==================================================

  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final nextLevel = currentLevel + 1;



    final count = await getLevelCount(

      worldId,

    );




    if(nextLevel > count){

      return;

    }




    await PuzzleProgressManager.unlockLevel(

      levelKey(

        worldId: worldId,

        levelNumber: nextLevel,

      ),

    );


  }







  //==================================================
  // نجوم العالم
  //==================================================

  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );



    int total = 0;




    for(final level in levels){


      total += await PuzzleProgressManager

          .getLevelStars(

        levelKey(

          worldId: worldId,

          levelNumber: level.levelNumber,

        ),

      );


    }



    return total;


  }







  //==================================================
  // هل العالم مكتمل
  //==================================================

  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );




    for(final level in levels){



      final completed =

      await PuzzleProgressManager.isCompleted(



        levelKey(

          worldId: worldId,

          levelNumber: level.levelNumber,

        ),



      );




      if(!completed){

        return false;

      }


    }



    return true;


  }







  //==================================================
  // المرحلة التالية
  //==================================================

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







  //==================================================
  // إعادة ضبط العالم
  //==================================================

  static Future<void> resetWorld(

      String worldId,

      ) async {



    final levels = await getLevels(

      worldId,

    );



    for(final level in levels){



      final key = levelKey(

        worldId: worldId,

        levelNumber: level.levelNumber,

      );




      // حذف الإكمال

      await PuzzleProgressManager.removeCompletedLevel(

        key,

      );




      // حذف النجوم

      await PuzzleProgressManager.removeLevelStars(

        key,

      );



    }


  }







}