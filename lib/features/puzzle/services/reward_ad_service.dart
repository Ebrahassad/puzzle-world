import 'package:flutter/material.dart';



class RewardAdService {



  static bool _isShowingAd = false;



  // =========================
  // إعلان متابعة لعبة محفوظة
  // =========================

  static Future<bool> showContinueAd() async {


    return await _showFakeAd(

      message:

      "🎬 جاري تحميل إعلان المتابعة...",


    );


  }







  // =========================
  // إعلان مكافأة
  // تلميحات + مضاعفة الجوائز
  // =========================

  static Future<bool> showRewardAd() async {


    return await _showFakeAd(

      message:

      "🎁 جاري تحميل إعلان المكافأة...",


    );


  }







  // =========================
  // محاكاة الإعلان
  // سيتم استبدالها بـ AdMob RewardedAd
  // =========================

  static Future<bool> _showFakeAd({

    required String message,

  }) async {



    if(_isShowingAd){

      return false;

    }




    _isShowingAd = true;




    debugPrint(message);





    await Future.delayed(

      const Duration(seconds:2),

    );





    _isShowingAd = false;




    return true;


  }





  // =========================
  // إغلاق حالة الإعلان
  // مفيد لاحقًا مع AdMob
  // =========================

  static void reset(){

    _isShowingAd = false;

  }



}