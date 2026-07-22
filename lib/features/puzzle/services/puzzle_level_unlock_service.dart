import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleLevelUnlockService {


  static Future<bool> checkUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    return await PuzzleProgressManager

        .isLevelUnlocked(

      "${worldId}_${level.id}",

    );


  }








  static Future<bool> unlockByStars({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    if(stars < level.requiredStars){

      return false;

    }





    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_${level.id}",

    );





    return true;


  }








  static Future<bool> unlockByAd({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){

      return false;

    }





    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_${level.id}",

    );





    return true;


  }








  static Future<void> unlockNext({

    required String worldId,

    required int currentLevel,

  }) async {



    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      currentLevel,

    );


  }








  static Future<List<bool>>

  getLevelsStatus({

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