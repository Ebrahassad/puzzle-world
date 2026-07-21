import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_result_model.dart';



class RewardManager {


  static const String coinsKey = "coins";

  static const String gemsKey = "gems";

  static const String puzzlesSolvedKey =
      "puzzles_solved";

  static const String dailyRewardKey =
      "daily_reward";





  static Future<int> getCoins() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(coinsKey) ?? 0;


  }






  static Future<int> getGems() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(gemsKey) ?? 0;


  }







  static Future<void> addCoins(int amount) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(coinsKey) ?? 0;



    await prefs.setInt(

      coinsKey,

      current + amount,

    );


  }








  static Future<void> addGems(int amount) async {


    final prefs =
    await SharedPreferences.getInstance();


    final current =
        prefs.getInt(gemsKey) ?? 0;



    await prefs.setInt(

      gemsKey,

      current + amount,

    );


  }









  // عند إكمال البازل

  static Future<RewardResultModel>

  completePuzzle({

    required int difficulty,

  }) async {



    int coins = 50;


    int gems = 0;





    // زيادة المكافأة حسب الصعوبة

    if(difficulty >= 2){


      coins = 100;


    }



    if(difficulty >= 3){


      coins = 150;

      gems = 1;


    }







    await addCoins(coins);




    if(gems > 0){


      await addGems(gems);


    }






    final prefs =

    await SharedPreferences.getInstance();



    final solved =

    prefs.getInt(

      puzzlesSolvedKey,

    ) ?? 0;



    await prefs.setInt(

      puzzlesSolvedKey,

      solved + 1,

    );







    return RewardResultModel(


      coins: coins,


      gems: gems,


    );



  }






  // مكافأة الإعلان

  static Future<void>

  rewardedAdBonus() async {


    await addCoins(100);


  }






  // الصندوق اليومي

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