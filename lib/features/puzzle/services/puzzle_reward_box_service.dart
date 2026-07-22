import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleRewardBoxService {


  static Future<RewardResultModel>

  openRewardBox({

    required int difficulty,

  }) async {



    return await RewardManager

        .completePuzzle(

      difficulty: difficulty,

    );


  }








  static Future<RewardResultModel>

  openAdRewardBox() async {



    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){


      return const RewardResultModel(

        coins: 0,

        gems: 0,

      );


    }





    return await RewardManager

        .rewardedAdBonus();


  }








  static Future<RewardResultModel>

  doubleRewardBox({

    required RewardResultModel reward,

  }) async {



    final watched =

    await RewardAdService

        .showDoubleRewardAd();





    if(!watched){


      return reward;


    }





    await RewardManager

        .addCoins(

      reward.coins,

    );





    if(reward.gems > 0){


      await RewardManager

          .addGems(

        reward.gems,

      );


    }





    return RewardResultModel(

      coins: reward.coins * 2,

      gems: reward.gems * 2,

    );


  }








  static Future<int> getCoins() async {



    return await RewardManager

        .getCoins();


  }








  static Future<int> getGems() async {



    return await RewardManager

        .getGems();


  }


}