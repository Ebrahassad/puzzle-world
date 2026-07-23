import '../managers/puzzle_progress_manager.dart';


class PuzzleSettingsService {


  const PuzzleSettingsService._();



  static Future<Map<String, dynamic>>

  getSettings() async {


    final sound =
        await PuzzleProgressManager
            .isSoundEnabled();


    final darkMode =
        await PuzzleProgressManager
            .isDarkMode();


    final vibration =
        await PuzzleProgressManager
            .isVibrationEnabled();


    return {

      "sound": sound,

      "darkMode": darkMode,

      "vibration": vibration,

    };


  }




  static Future<void> setSound(

      bool value,

      ) async {


    await PuzzleProgressManager
        .saveSoundEnabled(

      value,

    );


  }




  static Future<void> setDarkMode(

      bool value,

      ) async {


    await PuzzleProgressManager
        .saveDarkMode(

      value,

    );


  }




  static Future<void> setVibration(

      bool value,

      ) async {


    await PuzzleProgressManager
        .saveVibrationEnabled(

      value,

    );


  }




  static Future<void> resetSettings() async {


    await PuzzleProgressManager
        .saveSoundEnabled(

      true,

    );


    await PuzzleProgressManager
        .saveDarkMode(

      false,

    );


    await PuzzleProgressManager
        .saveVibrationEnabled(

      true,

    );


  }


}