import '../services/reward_ad_service.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleRewardAdService {


  const PuzzleRewardAdService._();





  //==================================================
  // 💡 إعلان تلميح
  //==================================================

  static Future<bool> watchAdForHint() async {

    try {


      final watched =

      await RewardAdService.showRewardAd();



      if(!watched){

        return false;

      }




      await PuzzleProgressManager.addHints(

        1,

      );




      return true;



    } catch(_){


      return false;


    }

  }








  //==================================================
  // 🔓 إعلان فتح مرحلة
  //==================================================

  static Future<bool> watchAdForUnlock({

    required String levelId,

  }) async {


    try {


      final watched =

      await RewardAdService.showRewardAd();




      if(!watched){

        return false;

      }




      await PuzzleProgressManager.unlockLevel(

        levelId,

      );




      return true;



    } catch(_){


      return false;


    }

  }









  //==================================================
  // ⭐ إعلان نجمة إضافية
  //==================================================

  static Future<bool> watchAdForExtraStars() async {


    try {


      final watched =

      await RewardAdService.showRewardAd();




      if(!watched){

        return false;

      }




      await PuzzleProgressManager.addStars(

        1,

      );




      return true;



    } catch(_){


      return false;


    }

  }









  //==================================================
  // 🎁 مضاعفة المكافأة بعد الفوز
  //==================================================

  static Future<bool> watchAdForDoubleReward() async {


    try {


      final result =

      await RewardAdService.showDoubleRewardAd();



      return result;



    } catch(_){


      return false;


    }


  }






  //==================================================
  // 🪙 مكافأة إعلان عامة
  //==================================================

  static Future<bool> watchAdForCoins() async {


    try {


      final watched =

      await RewardAdService.showRewardAd();



      if(!watched){

        return false;

      }




      await PuzzleProgressManager.addCoins(

        100,

      );




      return true;



    } catch(_){


      return false;


    }


  }




}