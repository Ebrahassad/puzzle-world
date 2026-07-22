import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_result_model.dart';


class RewardManager {


  static const String coinsKey =
      "puzzle_coins";


  static const String gemsKey =
      "puzzle_gems";


  static const String solvedKey =
      "puzzle_solved_count";


  static const String dailyRewardKey =
      "puzzle_daily_reward";



  // =========================
  // العملات
  // =========================


  static Future<int> getCoins() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(coinsKey) ?? 0;

  }




  static Future<void> addCoins(
      int amount,
      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(coinsKey) ?? 0;



    await prefs.setInt(

      coinsKey,

      current + amount,

    );


  }




  static Future<void> removeCoins(
      int amount,
      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(coinsKey) ?? 0;



    await prefs.setInt(

      coinsKey,

      current - amount < 0
          ? 0
          : current - amount,

    );


  }





  // =========================
  // الجواهر
  // =========================


  static Future<int> getGems() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(gemsKey) ?? 0;


  }






  static Future<void> addGems(
      int amount,
      ) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(gemsKey) ?? 0;



    await prefs.setInt(

      gemsKey,

      current + amount,

    );


  }







  // =========================
  // إنهاء لعبة البازل
  // =========================


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





    await addCoins(coins);



    if(gems > 0){

      await addGems(gems);

    }






    final prefs =
    await SharedPreferences.getInstance();



    final solved =
        prefs.getInt(solvedKey) ?? 0;



    await prefs.setInt(

      solvedKey,

      solved + 1,

    );







    return RewardResultModel(

      coins: coins,

      gems: gems,

    );


  }









  // =========================
  // مكافأة إعلان
  // =========================


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









  // =========================
  // المكافأة اليومية
  // =========================


  static Future<bool>

  canClaimDailyReward() async {



    final prefs =
    await SharedPreferences.getInstance();



    final saved =
        prefs.getString(

          dailyRewardKey,

        );




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

      dailyRewardKey,

      DateTime.now()

          .toIso8601String(),

    );





    await addCoins(100);


    await addGems(1);


  }



}