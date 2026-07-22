import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_result_model.dart';



class RewardManager {



  static const String coinsKey = "puzzle_coins";


  static const String gemsKey = "puzzle_gems";


  static const String puzzlesSolvedKey =
      "puzzle_solved";


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
  // إنهاء البازل
  // =========================


  static Future<RewardResultModel>

  completePuzzle({

    required int difficulty,

  }) async {



    int coins = 50;


    int gems = 0;




    // زيادة المكافأة حسب المستوى


    switch(difficulty){


      case 1:

        coins = 50;

        break;



      case 2:

        coins = 100;

        break;



      default:

        coins = 150;

        gems = 1;

        break;


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









  // =========================
  // مكافأة مشاهدة إعلان
  // =========================


  static Future<void>

  rewardedAdBonus() async {



    await addCoins(100);


  }









  // =========================
  // المكافأة اليومية
  // =========================


  static Future<bool>

  canClaimDailyReward() async {


    final prefs =

    await SharedPreferences.getInstance();



    final last =

    prefs.getString(

      dailyRewardKey,

    );



    if(last == null){

      return true;

    }




    final oldDate =

    DateTime.parse(last);



    final now =

    DateTime.now();




    return oldDate.day != now.day ||

        oldDate.month != now.month ||

        oldDate.year != now.year;



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