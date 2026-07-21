class RewardAdService {



  // مؤقتًا محاكاة نجاح الإعلان
  // لاحقًا يتم استبداله بـ AdMob RewardedAd



  static Future<bool> showContinueAd() async {


    await Future.delayed(

      const Duration(seconds:2),

    );


    return true;


  }





  static Future<bool> showRewardAd() async {


    await Future.delayed(

      const Duration(seconds:2),

    );


    return true;


  }


}