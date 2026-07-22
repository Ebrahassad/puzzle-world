import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';



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


  }







  //==================================================
  // فتح بالنجوم
  //==================================================

  static Future<bool> unlockByStars({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    final totalStars =

    await PuzzleProgressManager.getTotalStars();





    if(totalStars < level.requiredStars){

      return false;

    }






    await PuzzleProgressManager.unlockLevel(

      levelKey(

        worldId: worldId,

        levelId: level.id,

      ),

    );



    return true;


  }







  //==================================================
  // فتح بالإعلان
  //==================================================

  static Future<bool> unlockByAd({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    final watched =

    await RewardAdService.showRewardAd();





    if(!watched){

      return false;

    }






    await PuzzleProgressManager.unlockLevel(

      levelKey(

        worldId: worldId,

        levelId: level.id,

      ),

    );




    return true;


  }







  //==================================================
  // فتح المرحلة التالية
  //==================================================

  static Future<void> unlockNext({

    required String worldId,

    required int currentLevel,

  }) async {



    await PuzzleProgressManager.unlockNextLevel(

      worldId,

      currentLevel,

    );


  }







  //==================================================
  // حالة كل المراحل
  //==================================================

  static Future<List<bool>> getLevelsStatus({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) async {



    final result = <bool>[];



    for(final level in levels){



      result.add(

        await checkUnlocked(

          worldId: worldId,

          level: level,

        ),

      );


    }



    return result;


  }



}