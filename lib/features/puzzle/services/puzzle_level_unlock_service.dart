import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleLevelUnlockService {



  const PuzzleLevelUnlockService._();




  //==================================================
  // فحص فتح المرحلة
  //==================================================


  static Future<bool> checkUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }



    return await PuzzleProgressManager.isLevelUnlocked(

      _key(

        worldId,

        level.id,

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



    final stars =

    await PuzzleProgressManager.getTotalStars();




    if(stars < level.requiredStars){

      return false;

    }




    await PuzzleProgressManager.unlockLevel(

      _key(

        worldId,

        level.id,

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

      _key(

        worldId,

        level.id,

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



      final unlocked =

      await checkUnlocked(

        worldId: worldId,

        level: level,

      );



      result.add(unlocked);


    }





    return result;


  }






  //==================================================
  // مفتاح المرحلة الموحد
  //==================================================


  static String _key(

      String worldId,

      String levelId,

      ){



    return "${worldId}_$levelId";


  }



}