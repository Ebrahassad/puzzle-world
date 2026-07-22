import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_level_model.dart';



class PuzzleLevelProgressService {



  //==================================================
  // هل المرحلة مكتملة
  //==================================================


  static Future<bool> isLevelCompleted({

    required String worldId,

    required String levelId,

  }) async {


    return await PuzzleProgressManager.isCompleted(

      _key(worldId, levelId),

    );


  }





  //==================================================
  // إكمال المرحلة
  //==================================================


  static Future<void> completeLevel({

    required String worldId,

    required String levelId,

  }) async {


    await PuzzleProgressManager.completeLevel(

      _key(worldId, levelId),

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

      _key(worldId, levelId),

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

      _key(worldId, levelId),

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
  // تجهيز قائمة المراحل
  //==================================================


  static Future<List<PuzzleLevelModel>> prepareLevels({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {



    final result = <PuzzleLevelModel>[];



    for(final level in levels){



      final unlocked =

      await isLevelUnlocked(

        worldId: worldId,

        levelId: level.id,

      );




      result.add(

        level.copyWith(

          unlocked: unlocked,

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



      final completed =

      await isLevelCompleted(

        worldId: worldId,

        levelId: level.id,

      );



      if(completed){

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
  // إنشاء مفتاح موحد
  //==================================================


  static String _key(

      String worldId,

      String levelId,

      ){


    return "${worldId}_$levelId";


  }



}