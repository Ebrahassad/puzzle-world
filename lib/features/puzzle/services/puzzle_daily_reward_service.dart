import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleDailyRewardService {


  static Future<bool> canClaim() async {



    final lastClaim =

    await PuzzleProgressManager

        .getLastDailyReward();





    if(lastClaim == null){

      return true;

    }





    final now = DateTime.now();





    final difference =

    now.difference(lastClaim);





    return difference.inHours >= 24;


  }








  static Future<RewardResultModel?>

  claimReward() async {



    final available =

    await canClaim();





    if(!available){

      return null;

    }





    final reward =

    await RewardManager

        .dailyReward();





    await PuzzleProgressManager

        .saveLastDailyReward(

      DateTime.now(),

    );





    return reward;


  }








  static Future<Duration>

  getRemainingTime() async {



    final lastClaim =

    await PuzzleProgressManager

        .getLastDailyReward();





    if(lastClaim == null){

      return Duration.zero;

    }





    final nextClaim =

    lastClaim.add(

      const Duration(hours:24),

    );





    final now = DateTime.now();





    if(now.isAfter(nextClaim)){

      return Duration.zero;

    }





    return nextClaim.difference(

      now,

    );


  }


}