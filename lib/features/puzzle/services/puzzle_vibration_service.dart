import 'package:flutter/services.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleVibrationService {


  const PuzzleVibrationService._();




  //==================================================
  // ✨ اهتزاز خفيف
  //==================================================

  static Future<void> vibrateShort() async {


    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback.lightImpact();


  }








  //==================================================
  // 🏆 اهتزاز نجاح
  //==================================================

  static Future<void> vibrateSuccess() async {


    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback.mediumImpact();


  }








  //==================================================
  // ❌ اهتزاز خطأ
  //==================================================

  static Future<void> vibrateError() async {


    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback.heavyImpact();


  }








  //==================================================
  // ⚙️ تغيير الحالة
  //==================================================

  static Future<void> setEnabled(

      bool value,

      ) async {


    await PuzzleProgressManager

        .saveVibrationEnabled(

      value,

    );


  }








  //==================================================
  // 🔍 حالة الاهتزاز
  //==================================================

  static Future<bool> isEnabled() async {


    return await PuzzleProgressManager

        .isVibrationEnabled();


  }


}