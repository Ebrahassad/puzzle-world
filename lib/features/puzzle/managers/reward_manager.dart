import '../models/reward_result_model.dart';
import '../managers/puzzle_progress_manager.dart';


class RewardManager {


  const RewardManager._();



  //==================================================
  // 🪙 العملات
  //==================================================


  static Future<int> getCoins() async {

    return PuzzleProgressManager.getCoins();

  }





  static Future<void> addCoins(

      int amount,

      ) async {


    await PuzzleProgressManager.addCoins(

      amount,

    );


  }





  static Future<void> removeCoins(

      int amount,

      ) async {


    await PuzzleProgressManager.addCoins(

      -amount,

    );


  }







  //==================================================
  // 💎 الجواهر
  //==================================================


  static Future<int> getGems() async {


    return PuzzleProgressManager.getGems();


  }






  static Future<void> addGems(

      int amount,

      ) async {


    await PuzzleProgressManager.addGems(

      amount,

    );


  }






  static Future<void> removeGems(

      int amount,

      ) async {


    await PuzzleProgressManager.addGems(

      -amount,

    );


  }







  //==================================================
  // 🎮 إكمال البازل وإعطاء المكافأة
  //==================================================


  static Future<RewardResultModel>

  completePuzzle({

    required int difficulty,

  }) async {



    int coins;

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






    await addCoins(

      coins,

    );






    if(gems > 0){


      await addGems(

        gems,

      );


    }







    return RewardResultModel(

      coins: coins,

      gems: gems,

    );


  }








  //==================================================
  // 🎬 مكافأة الإعلان
  //==================================================


  static Future<RewardResultModel>

  rewardedAdBonus() async {



    const reward = RewardResultModel(

      coins:100,

      gems:0,

    );





    await addCoins(

      reward.coins,

    );






    return reward;


  }








  //==================================================
  // 🎁 المكافأة اليومية
  //==================================================


  static Future<bool>

  canClaimDailyReward() async {



    final prefs =

    await SharedPreferences.getInstance();



    const key =

        "puzzle_daily_reward";



    final saved =

    prefs.getString(key);





    if(saved == null){

      return true;

    }






    final last =

    DateTime.parse(saved);





    final now =

    DateTime.now();





    return

        last.year != now.year ||

            last.month != now.month ||

            last.day != now.day;


  }








  static Future<void>

  claimDailyReward() async {



    final prefs =

    await SharedPreferences.getInstance();



    await prefs.setString(

      "puzzle_daily_reward",

      DateTime.now()

          .toIso8601String(),

    );





    await addCoins(

      100,

    );





    await addGems(

      1,

    );


  }




}