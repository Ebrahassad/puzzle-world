import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/reward_result_model.dart';
import '../managers/puzzle_progress_manager.dart';



class RewardManager {

 const RewardManager._();

static final ValueNotifier<int> rewardNotifier =
    ValueNotifier(0);

 





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





  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    try {
      await PuzzleProgressManager.addCoins(amount);
      rewardNotifier.notifyListeners();
    } catch (_) {}
  }


//==================================================
// 🪙 خصم العملات
//==================================================

static Future<bool> spendCoins(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }

  try {

    final result =
        await PuzzleProgressManager.spendCoins(
          amount,
        );


    if(result){

      rewardNotifier.notifyListeners();

    }


    return result;


  } catch (_) {

    return false;

  }

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





  static Future<void> addGems(int amount) async {
    if (amount <= 0) return;

    try {
      await PuzzleProgressManager.addGems(amount);
      rewardNotifier.notifyListeners();
    } catch (_) {}
  }


//==================================================
// 💎 خصم الجواهر
//==================================================

static Future<bool> spendGems(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }

  try {

    final result =
        await PuzzleProgressManager.spendGems(
          amount,
        );


    if(result){

      rewardNotifier.notifyListeners();

    }


    return result;


  } catch (_) {

    return false;

  }

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





  static Future<void> addStars(int amount) async {
    if (amount <= 0) return;

    try {
      await PuzzleProgressManager.addStars(amount);
      rewardNotifier.notifyListeners();
    } catch (_) {}
  }


//==================================================
// ⭐ خصم النجوم
//==================================================

static Future<bool> spendStars(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }

  try {

    final result =
        await PuzzleProgressManager.spendStars(
          amount,
        );


    if(result){

      rewardNotifier.notifyListeners();

    }


    return result;


  } catch (_) {

    return false;

  }

}




  //==================================================
  // 🎁 تطبيق المكافأة الموحد
  //==================================================


  static Future<void> applyReward(
      RewardResultModel reward,
  ) async {

    if(reward.coins > 0){
      await PuzzleProgressManager.addCoins(
        reward.coins,
      );
    }

    if(reward.gems > 0){
      await PuzzleProgressManager.addGems(
        reward.gems,
      );
    }

    if(reward.stars > 0){
      await PuzzleProgressManager.addStars(
        reward.stars,
      );
    }

    if(reward.hints > 0){
      await PuzzleProgressManager.addHints(
        reward.hints,
      );
    }

    rewardNotifier.notifyListeners();

  }

  //==================================================
  // 🎮 مكافأة إنهاء البازل
  //==================================================


  static Future<RewardResultModel?> completePuzzle({
  required String rewardKey,
}) async {

  try {

    final claimed =
        await PuzzleProgressManager.isRewardClaimed(
      rewardKey,
    );

    if (claimed) {
      return null;
    }

    const reward = RewardResultModel(
      stars: 1,
    );

    await applyReward(reward);

    await PuzzleProgressManager.markRewardClaimed(
      rewardKey,
    );

    return reward;

  } catch (_) {

    return null;

  }

}




  //==================================================
  // 📺 مكافأة مشاهدة الإعلان
  //==================================================


  static Future<RewardResultModel?>

  rewardedAdBonus() async {


    try {


      const reward = RewardResultModel(

        coins:100,

        stars:1,

      );





      await applyReward(

        reward,

      );





      return reward;



    }catch(_){


      return null;


    }


  }








  //==================================================
  // 🎁 فتح صندوق المكافأة الملكي
  //==================================================

  static Future<RewardResultModel?> openRewardChest() async {

    try {

      const reward = RewardResultModel(
        coins: 100,
        gems: 1,
        stars: 1,
      );


      await applyReward(
        reward,
      );


      return reward;


    } catch (_) {

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


  static const String dailyRewardKey =
      "puzzle_daily_reward";




  static Future<bool> canClaimDailyReward() async {


    try {


      final prefs =
          await SharedPreferences.getInstance();



      final saved =
          prefs.getString(dailyRewardKey);




      if(saved == null){

        return true;

      }





      final last =
          DateTime.tryParse(saved);



      if(last == null){

        return true;

      }





      final now =
          DateTime.now();





      return last.year != now.year ||
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

        dailyRewardKey,

        DateTime.now()

            .toIso8601String(),

      );








      const reward = RewardResultModel(

        coins:100,

        gems:1,

        stars:1,

      );






      await applyReward(

        reward,

      );






      return reward;



    }catch(_){


      return null;


    }


  }









  //==================================================
  // 🧹 حذف المكافأة اليومية
  //==================================================


  static Future<void>

  resetDailyReward() async {


    try {


      final prefs =
          await SharedPreferences.getInstance();




      await prefs.remove(

        dailyRewardKey,

      );



    }catch(_){}



  }








  //==================================================
  // 📦 قراءة جميع المكافآت الحالية
  //==================================================


  static Future<RewardResultModel>

  getReward() async {


    try {


      return RewardResultModel(

        coins:

        await getCoins(),



        gems:

        await getGems(),



        stars:

        await getStars(),



      );



    }catch(_){


      return const RewardResultModel();


    }


  }

  //==================================================
  // توافق مع شاشات المكافآت القديمة
  //==================================================

  static Future<void> addStar() async {

    await addStars(1);

  }



  static Future<void> addGem() async {

    await addGems(1);

  }

//==================================================
// 📺 إضافة تلميحة من الإعلان
//==================================================

static Future<void> addHintFromAd() async {

  try {

    await PuzzleProgressManager.addHints(
      1,
    );

    rewardNotifier.notifyListeners();

  } catch (_) {}

}

}
