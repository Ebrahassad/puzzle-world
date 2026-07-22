import '../models/reward_result_model.dart';

import '../models/puzzle_level_model.dart';

import '../managers/reward_manager.dart';



class PuzzleLevelRewardService {


  static Future<RewardResultModel>

  calculateReward({

    required PuzzleLevelModel level,

    required int stars,

  }) async {



    final difficulty =

    level.gridSize;



    return await RewardManager

        .completePuzzle(

      difficulty: difficulty,

    );


  }








  static int calculateStars({

    required int moves,

    required int seconds,

    required PuzzleLevelModel level,

  }) {



    int stars = 1;





    final bestMoves =

    level.gridSize *

        level.gridSize *

        2;





    if(moves <= bestMoves){

      stars++;

    }





    if(seconds <= level.gridSize * 60){

      stars++;

    }





    if(stars > 3){

      stars = 3;

    }





    return stars;


  }








  static String rewardMessage(

      RewardResultModel reward,

      ) {



    String message =

        "🪙 +${reward.coins}";





    if(reward.gems > 0){


      message +=

          "  💎 +${reward.gems}";


    }





    return message;


  }


}