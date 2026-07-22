import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleUnlockService {


  static Future<bool> canUnlockLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    return stars >= level.requiredStars;


  }








  static Future<bool> unlockLevelWithStars({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    final allowed =

    await canUnlockLevel(

      worldId: worldId,

      level: level,

    );





    if(!allowed){

      return false;

    }





    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_${level.id}",

    );





    return true;


  }








  static Future<bool> unlockLevelWithCoins({

    required String worldId,

    required PuzzleLevelModel level,

    required int cost,

  }) async {



    final coins =

    await RewardManager

        .getCoins();





    if(coins < cost){

      return false;

    }





    await RewardManager

        .removeCoins(

      cost,

    );





    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_${level.id}",

    );





    return true;


  }








  static Future<bool> unlockLevelWithAd({

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








  static Future<bool> isLevelUnlocked({

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








  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      currentLevel,

    );


  }








  static Future<void> unlockWorld({

    required PuzzleModel world,

  }) async {



    await PuzzleProgressManager

        .unlockWorld(

      world.id,

    );


  }








  static Future<bool> isWorldUnlocked({

    required String worldId,

  }) async {



    return await PuzzleProgressManager

        .isWorldUnlocked(

      worldId,

    );


  }








  static Future<void> unlockAllLevels({

    required String worldId,

  }) async {



    await PuzzleProgressManager

        .unlockAllLevels(

      worldId,

    );


  }

}