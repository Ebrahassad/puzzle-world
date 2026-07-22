import '../services/reward_ad_service.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleRewardAdService {


  static Future<bool> watchAdForHint() async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){

      return false;

    }





    await PuzzleProgressManager

        .addHints(

      1,

    );





    return true;


  }








  static Future<bool> watchAdForUnlock({

    required String levelId,

  }) async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){

      return false;

    }





    await PuzzleProgressManager

        .unlockLevel(

      levelId,

    );





    return true;


  }








  static Future<bool> watchAdForExtraStars() async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){

      return false;

    }





    await PuzzleProgressManager

        .addStars(

      1,

    );





    return true;


  }








  static Future<bool> watchAdForDoubleReward() async {



    return await RewardAdService

        .showDoubleRewardAd();


  }


}