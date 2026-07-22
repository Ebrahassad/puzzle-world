import 'package:flutter/material.dart';



class RewardAdService {



  static bool _isShowingAd = false;


  static bool get isShowingAd => _isShowingAd;






  // =========================
  // إعلان متابعة لعبة محفوظة
  // =========================


  static Future<bool> showContinueAd() async {



    return await _showFakeAd(

      message:

      "🎬 جاري تحميل إعلان المتابعة...",


      duration:

      const Duration(seconds:2),

    );


  }









  // =========================
  // إعلان مكافأة
  // =========================


  static Future<bool> showRewardAd() async {



    return await _showFakeAd(

      message:

      "🎁 جاري تحميل إعلان المكافأة...",


      duration:

      const Duration(seconds:2),

    );


  }









  // =========================
  // إعلان مضاعفة المكافأة
  // =========================


  static Future<bool> showDoubleRewardAd() async {



    return await _showFakeAd(

      message:

      "✨ جاري تشغيل إعلان مضاعفة الجائزة...",


      duration:

      const Duration(seconds:3),

    );


  }









  // =========================
  // محاكاة الإعلان
  // لاحقاً تستبدل بـ AdMob RewardedAd
  // =========================


  static Future<bool> _showFakeAd({

    required String message,

    Duration duration =

    const Duration(seconds:2),

  }) async {



    if(_isShowingAd){



      return false;



    }







    _isShowingAd = true;





    debugPrint(message);






    await Future.delayed(

      duration,

    );







    _isShowingAd = false;






    return true;



  }









  // =========================
  // إعادة ضبط الحالة
  // =========================


  static void reset(){



    _isShowingAd = false;



  }






}