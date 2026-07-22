import 'package:flutter/material.dart';


class RewardAdService {



  // =========================
  // إعلان متابعة اللعبة المحفوظة
  // =========================


  static Future<bool> showContinueAd() async {



    return await _showFakeAd(

      message: "🎬 جاري تحميل الإعلان للمتابعة...",


    );


  }






  // =========================
  // إعلان مكافأة
  // (تلميحات - مضاعفة الجوائز)
  // =========================


  static Future<bool> showRewardAd() async {



    return await _showFakeAd(

      message: "🎁 جاري مشاهدة الإعلان للحصول على المكافأة...",


    );


  }







  // =========================
  // محاكاة الإعلان مؤقتًا
  // سيتم استبدالها بـ AdMob
  // =========================


  static Future<bool> _showFakeAd({

    required String message,

  }) async {



    debugPrint(message);



    await Future.delayed(

      const Duration(seconds:2),

    );



    return true;


  }




}
