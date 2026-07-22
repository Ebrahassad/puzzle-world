import 'package:flutter/services.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleVibrationService {


  static Future<void> vibrateShort() async {



    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback

        .lightImpact();


  }








  static Future<void> vibrateSuccess() async {



    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback

        .mediumImpact();


  }








  static Future<void> vibrateError() async {



    final enabled =

    await PuzzleProgressManager

        .isVibrationEnabled();





    if(!enabled){

      return;

    }





    await HapticFeedback

        .heavyImpact();


  }








  static Future<void> setEnabled(

      bool value,

      ) async {



    await PuzzleProgressManager

        .saveVibrationEnabled(

      value,

    );


  }








  static Future<bool> isEnabled() async {



    return await PuzzleProgressManager

        .isVibrationEnabled();


  }


}