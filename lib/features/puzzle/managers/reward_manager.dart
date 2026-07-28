import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_result_model.dart';
import '../managers/puzzle_progress_manager.dart';



class RewardManager {


  const RewardManager._();





  //==================================================
  // 🪙 العملات
  //==================================================


  static Future<int> getCoins() async {

    try {

      return await PuzzleProgressManager.getCoins();

    } catch (_) {

      return 0;

    }

  }





  static Future<void> addCoins(

      int amount,

      ) async {


    if(amount <= 0){

      return;

    }


    try {

      await PuzzleProgressManager.addCoins(amount);

    } catch (_) {}

  }





  static Future<void> removeCoins(

      int amount,

      ) async {


    if(amount <= 0){

      return;

    }


    try {

      await PuzzleProgressManager.addCoins(-amount);

    } catch (_) {}

  }








  //==================================================
  // 💎 الجواهر
  //==================================================


  static Future<int> getGems() async {


    try {

      return await PuzzleProgressManager.getGems();

    } catch (_) {

      return 0;

    }


  }





  static Future<void> addGems(

      int amount,

      ) async {


    if(amount <= 0){

      return;

    }


    try {

      await PuzzleProgressManager.addGems(amount);

    } catch (_) {}

  }





  static Future<void> removeGems(

      int amount,

      ) async {


    if(amount <= 0){

      return;

    }


    try {

      await PuzzleProgressManager.addGems(-amount);

    } catch (_) {}

  }








  //==================================================
  // ⭐ Golden Star
  //==================================================


  static Future<int> getStars() async {


    try {

      return await PuzzleProgressManager.getStars();

    } catch (_) {

      return 0;

    }


  }





  static Future<void> addStars(

      int amount,

      ) async {


    if(amount <= 0){

      return;

    }


    try {

      await PuzzleProgressManager.addStars(amount);

    } catch (_) {}

  }









  //==================================================
  // 🎮 مكافأة إنهاء البازل
  //==================================================


  static Future<RewardResultModel?>

  completePuzzle({

    required int difficulty,

    required String rewardKey,

  }) async {


    try {


      final claimed =

      await PuzzleProgressManager.isRewardClaimed(

        rewardKey,

      );





      if(claimed){

        return null;

      }






      RewardResultModel reward;





      switch(difficulty){


        case 1:

          reward = const RewardResultModel(

            coins:50,

            stars:1,

          );

          break;




        case 2:

          reward = const RewardResultModel(

            coins:100,

            stars:2,

          );

          break;




        case 3:

          reward = const RewardResultModel(

            coins:150,

            gems:1,

            stars:3,

          );

          break;




        default:

          reward = const RewardResultModel(

            coins:200,

            gems:2,

            stars:5,

          );

          break;


      }






      await _applyReward(reward);






      await PuzzleProgressManager.markRewardClaimed(

        rewardKey,

      );






      return reward;



    }catch(_){


      return null;


    }


  }









  //==================================================
  // تطبيق المكافأة
  //==================================================


  static Future<void> _applyReward(

      RewardResultModel reward,

      ) async {


    await addCoins(

      reward.coins,

    );


    await addGems(

      reward.gems,

    );


    await addStars(

      reward.stars,

    );


  }


  //==================================================
  // 🎬 مكافأة مشاهدة الإعلان
  //==================================================


  static Future<RewardResultModel?>

  rewardedAdBonus() async {


    try {


      const reward = RewardResultModel(

        coins:100,

        stars:1,

      );





      await _applyReward(

        reward,

      );





      return reward;



    }catch(_){


      return null;


    }


  }









  //==================================================
  // ⭐ مضاعفة المكافأة
  //==================================================


  static Future<RewardResultModel>

  doubleReward(

      RewardResultModel reward,

      ) async {


    try {


      return reward.multiply(2);



    }catch(_){


      return reward;


    }


  }









  //==================================================
  // 🎁 المكافأة اليومية
  //==================================================


  static Future<bool>

  canClaimDailyReward() async {


    try {


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



    }catch(_){


      return true;


    }


  }









  static Future<RewardResultModel?>

  claimDailyReward() async {


    try {


      final available =

      await canClaimDailyReward();





      if(!available){

        return null;

      }






      final prefs =

      await SharedPreferences.getInstance();






      await prefs.setString(

        "puzzle_daily_reward",

        DateTime.now()

            .toIso8601String(),

      );








      const reward = RewardResultModel(

        coins:100,

        gems:1,

        stars:1,

      );








      await _applyReward(

        reward,

      );







      return reward;



    }catch(_){


      return null;


    }


  }









  //==================================================
  // 🧹 إعادة ضبط المكافأة اليومية
  //==================================================


  static Future<void>

  resetDailyReward() async {


    try {


      final prefs =

      await SharedPreferences.getInstance();





      await prefs.remove(

        "puzzle_daily_reward",

      );



    }catch(_){}



  }


  //==================================================
  // 📦 جميع بيانات المكافآت
  //==================================================

  static Future<RewardResultModel> getReward() async {

    try {

      return RewardResultModel(

        coins: await getCoins(),

        gems: await getGems(),

        stars: await getStars(),

      );

    } catch (_) {

      return const RewardResultModel();

    }

  }


}