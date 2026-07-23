import '../managers/puzzle_progress_manager.dart';


class PuzzleSoundSettingsService {


  const PuzzleSoundSettingsService._();


  static Future<bool> isEnabled() async {


    return await PuzzleProgressManager
        .isSoundEnabled();


  }


  static Future<void> enable() async {


    await PuzzleProgressManager
        .saveSoundEnabled(true);


  }


  static Future<void> disable() async {


    await PuzzleProgressManager
        .saveSoundEnabled(false);


  }


  static Future<void> toggle() async {


    final current = await isEnabled();


    await PuzzleProgressManager
        .saveSoundEnabled(!current);


  }


  static Future<void> setValue(
      bool value,
      ) async {


    await PuzzleProgressManager
        .saveSoundEnabled(value);


  }


}