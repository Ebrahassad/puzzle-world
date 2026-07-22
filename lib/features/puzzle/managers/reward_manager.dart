import '../models/reward_result_model.dart';
import 'puzzle_progress_manager.dart';


class RewardManager {


  const RewardManager._();



  //========================================
  // 🪙 قراءة العملات
  //========================================

  static Future<int> getCoins() async {

    return PuzzleProgressManager.getCoins();

  }





  //========================================
  // إضافة عملات
  //========================================

  static Future<void> addCoins(

      int amount,

      ) async {


    await PuzzleProgressManager.addCoins(

      amount,

    );


  }






  //========================================
  // خصم عملات
  //========================================

  static Future<void> removeCoins(

      int amount,

      ) async {


    await PuzzleProgressManager.addCoins(

      -amount,

    );


  }





  //========================================
  // 💎 قراءة الجواهر
  //========================================

  static Future<int> getGems() async {


    return PuzzleProgressManager.getGems();


  }





  //========================================
  // إضافة جواهر
  //========================================

  static Future<void> addGems(

      int amount,

      ) async {


    await PuzzleProgressManager.addGems(

      amount,

    );


  }





  //========================================
  // 🎉 مكافأة إنهاء البازل
  //========================================

  static Future<RewardResultModel>

  completePuzzle({

    required int difficulty,

  }) async {



    int coins = 0;

    int gems = 0;



    switch(difficulty){


      case 1:

        coins = 50;

        break;



      case 2:

        coins = 100;

        break;



      case 3:

        coins = 150;

        gems = 1;

        break;



      default:

        coins = 200;

        gems = 2;

        break;


    }




    await PuzzleProgressManager.addCoins(

      coins,

    );




    if(gems > 0){


      await PuzzleProgressManager.addGems(

        gems,

      );


    }





    return RewardResultModel(

      coins: coins,

      gems: gems,

    );


  }







  //========================================
  // 🎬 مكافأة الإعلان
  //========================================

  static Future<RewardResultModel>

  rewardedAdBonus() async {



    const reward = RewardResultModel(

      coins:100,

      gems:0,

    );





    await PuzzleProgressManager.addCoins(

      reward.coins,

    );





    return reward;


  }







  //========================================
  // 🎁 المكافأة اليومية
  //========================================

  static Future<void>

  claimDailyReward() async {



    await PuzzleProgressManager.addCoins(

      100,

    );



    await PuzzleProgressManager.addGems(

      1,

    );


  }



}