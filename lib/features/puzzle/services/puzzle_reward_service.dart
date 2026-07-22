import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleRewardService {


  static Future<RewardResultModel> completeLevelReward({

    required int difficulty,

    required int stars,

    String? levelId,

  }) async {



    if(levelId != null){


      final claimed =

      await PuzzleProgressManager

          .isRewardClaimed(

        levelId,

      );



      if(claimed){


        return const RewardResultModel(

          coins: 0,

          gems: 0,

        );


      }


    }





    final reward =

    await RewardManager.completePuzzle(

      difficulty: difficulty,

    );





    if(stars > 0){


      await PuzzleProgressManager

          .addStars(

        stars,

      );


    }





    if(levelId != null){


      await PuzzleProgressManager

          .markRewardClaimed(

        levelId,

      );


    }





    return reward;


  }








  static Future<RewardResultModel>

  doubleReward() async {



    final watched =

    await RewardAdService

        .showDoubleRewardAd();





    if(!watched){


      return const RewardResultModel(

        coins: 0,

        gems: 0,

      );


    }





    final reward =

    await RewardManager

        .rewardedAdBonus();





    return reward;


  }








  static Future<RewardResultModel>

  watchHintReward() async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){


      return const RewardResultModel(

        coins: 0,

        gems: 0,

      );


    }





    await PuzzleProgressManager

        .addHints(

      5,

    );





    return const RewardResultModel(

      coins: 100,

      gems: 0,

    );


  }








  static Future<RewardResultModel>

  dailyReward() async {



    final available =

    await RewardManager

        .canClaimDailyReward();





    if(!available){


      return const RewardResultModel(

        coins: 0,

        gems: 0,

      );


    }





    await RewardManager

        .claimDailyReward();





    return const RewardResultModel(

      coins: 100,

      gems: 1,

    );


  }








  static Future<int>

  getCoins() async {


    return await RewardManager

        .getCoins();


  }








  static Future<int>

  getGems() async {


    return await RewardManager

        .getGems();


  }








  static Future<void>

  addCoins(

      int amount,

      ) async {



    await RewardManager

        .addCoins(

      amount,

    );


  }








  static Future<void>

  addGems(

      int amount,

      ) async {



    await RewardManager

        .addGems(

      amount,

    );


  }

}