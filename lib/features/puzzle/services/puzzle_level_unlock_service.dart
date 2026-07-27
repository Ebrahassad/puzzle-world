import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/puzzle_reward_ad_service.dart';



class PuzzleLevelUnlockService {


  const PuzzleLevelUnlockService._();





  //==================================================
  // مفتاح المرحلة الموحد
  //==================================================

  static String levelKey({

    required String worldId,

    required String levelId,

  }) {


    return "${worldId}_$levelId";


  }







  //==================================================
  // فحص فتح المرحلة
  //==================================================

  static Future<bool> checkUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    try {


      // أول مرحلة مفتوحة دائماً

      if(level.levelNumber == 1){

        return true;

      }





      if(level.unlocked){

        return true;

      }







      return await PuzzleProgressManager.isLevelUnlocked(

        levelKey(

          worldId: worldId,

          levelId: level.id,

        ),

      );



    } catch(_){

      return false;

    }


  }







  //==================================================
  // فتح بالنجوم
  //==================================================

  static Future<bool> unlockByStars({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    try {


      final totalStars =

      await PuzzleProgressManager.getTotalStars();





      if(totalStars < level.requiredStars){

        return false;

      }







      await PuzzleProgressManager.unlockLevel(

        levelKey(

          worldId:worldId,

          levelId:level.id,

        ),

      );





      return true;



    } catch(_){

      return false;

    }


  }







  //==================================================
  // فتح بالإعلان
  //==================================================

  static Future<bool> unlockByAd({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    try {


      final watched =

      await PuzzleRewardAdService.watchAdForUnlock(

        levelId:

        levelKey(

          worldId:worldId,

          levelId:level.id,

        ),

      );







      if(!watched){

        return false;

      }







      return true;



    } catch(_){

      return false;

    }


  }







  //==================================================
  // فتح المرحلة التالية
  //==================================================

  static Future<void> unlockNext({

    required String worldId,

    required int currentLevel,

  }) async {


    try {


      await PuzzleProgressManager.unlockNextLevel(

        worldId,

        currentLevel,

      );


    } catch(_){}


  }







  //==================================================
  // حالة كل المراحل
  //==================================================

  static Future<List<bool>> getLevelsStatus({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {


    try {


      final result = <bool>[];



      for(final level in levels){


        result.add(

          await checkUnlocked(

            worldId:worldId,

            level:level,

          ),

        );


      }



      return result;



    } catch(_){

      return [];

    }


  }



}