import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_level_model.dart';



class PuzzleLevelProgressService {



  const PuzzleLevelProgressService._();





  //==================================================
  // إنشاء مفتاح المرحلة
  //==================================================

  static String levelKey({

    required String worldId,

    required String levelId,

  }) {

    return "${worldId}_$levelId";

  }







  //==================================================
  // هل المرحلة مكتملة
  //==================================================

  static Future<bool> isLevelCompleted({

    required String worldId,

    required String levelId,

  }) async {


    return await PuzzleProgressManager.isCompleted(

      levelKey(

        worldId: worldId,

        levelId: levelId,

      ),

    );


  }







  //==================================================
  // إكمال مرحلة
  //==================================================

  static Future<void> completeLevel({

    required String worldId,

    required String levelId,

  }) async {


    await PuzzleProgressManager.completeLevel(

      levelKey(

        worldId: worldId,

        levelId: levelId,

      ),

    );


  }







  //==================================================
  // هل المرحلة مفتوحة
  //==================================================

  static Future<bool> isLevelUnlocked({

    required String worldId,

    required String levelId,

  }) async {


    return await PuzzleProgressManager.isLevelUnlocked(

      levelKey(

        worldId: worldId,

        levelId: levelId,

      ),

    );


  }







  //==================================================
  // فتح مرحلة
  //==================================================

  static Future<void> unlockLevel({

    required String worldId,

    required String levelId,

  }) async {


    await PuzzleProgressManager.unlockLevel(

      levelKey(

        worldId: worldId,

        levelId: levelId,

      ),

    );


  }







  //==================================================
  // فتح المرحلة التالية
  //==================================================

  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {


    await PuzzleProgressManager.unlockNextLevel(

      worldId,

      currentLevel,

    );


  }







  //==================================================
  // تجهيز المراحل حسب تقدم اللاعب
  //==================================================

  static Future<List<PuzzleLevelModel>> prepareLevels({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {


    final result = <PuzzleLevelModel>[];



    for(final level in levels){



      final unlocked =

      level.levelNumber == 1 ||

      await isLevelUnlocked(

        worldId: worldId,

        levelId: level.id,

      );





      final completed =

      await isLevelCompleted(

        worldId: worldId,

        levelId: level.id,

      );





      final stars =

      await PuzzleProgressManager.getLevelStars(

        levelKey(

          worldId: worldId,

          levelId: level.id,

        ),

      );





      result.add(

        level.copyWith(

          unlocked: unlocked,

          completed: completed,

          earnedStars: stars,

        ),

      );


    }




    return result;


  }







  //==================================================
  // عدد المراحل المكتملة
  //==================================================

  static Future<int> getCompletedLevelsCount({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {


    int count = 0;




    for(final level in levels){



      if(await isLevelCompleted(

        worldId: worldId,

        levelId: level.id,

      )){


        count++;

      }


    }



    return count;


  }







  //==================================================
  // نسبة التقدم
  //==================================================

  static Future<double> getProgressPercent({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {



    if(levels.isEmpty){

      return 0;

    }




    final completed =

    await getCompletedLevelsCount(

      worldId: worldId,

      levels: levels,

    );





    return completed / levels.length;


  }







  //==================================================
  // نجوم العالم
  //==================================================

  static Future<int> getWorldStars({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {



    int total = 0;



    for(final level in levels){



      total += await PuzzleProgressManager.getLevelStars(

        levelKey(

          worldId: worldId,

          levelId: level.id,

        ),

      );


    }



    return total;


  }



}