import '../managers/ads_manager.dart';

class RewardAdService {

  static bool _isShowingAd = false;

  static bool get isShowingAd => _isShowingAd;


  // إعلان متابعة لعبة محفوظة
  static Future<bool> showContinueAd() async {

    if (_isShowingAd) {
      return false;
    }

    _isShowingAd = true;

    bool completed = false;


    AdsManager().showRewardedAd(

      onRewardEarned: () {

        completed = true;

      },

      onAdFailed: () {

        completed = false;

      },

    );


    // انتظار انتهاء الإعلان
    while (AdsManager().isShowing) {

      await Future.delayed(
        const Duration(milliseconds: 100),
      );

    }


    _isShowingAd = false;

    return completed;

  }



  // إعلان مكافأة عام
  static Future<bool> showRewardAd() async {

    return showContinueAd();

  }



  // إعلان مضاعفة المكافأة
  static Future<bool> showDoubleRewardAd() async {

    return showContinueAd();

  }



  static void reset(){

    _isShowingAd = false;

  }

}