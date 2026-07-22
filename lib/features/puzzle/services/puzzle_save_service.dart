import '../engine/puzzle_piece.dart';

import '../managers/puzzle_progress_manager.dart';


class PuzzleSaveService {


  //==================================================
  // 💾 حفظ اللعبة الحالية
  //==================================================

  static Future<void> saveGame({

    required String puzzleId,

    required String levelId,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {


    await PuzzleProgressManager.saveProgress(

      puzzleId: puzzleId,

      levelId: levelId,

      pieces: pieces,

      moves: moves,

      seconds: seconds,

    );


  }





  //==================================================
  // 📂 تحميل اللعبة المحفوظة
  //==================================================

  static Future<Map<String,dynamic>?>

  loadGame() async {


    return await PuzzleProgressManager.loadProgress();


  }





  //==================================================
  // هل يوجد حفظ لهذه المرحلة
  //==================================================

  static Future<bool> hasSavedGame({

    required String puzzleId,

    required String levelId,

  }) async {


    final saved = await loadGame();


    if(saved == null){

      return false;

    }



    return saved["puzzleId"] == puzzleId &&

        saved["levelId"] == levelId;


  }





  //==================================================
  // حذف الحفظ الحالي
  //==================================================

  static Future<void> clearGame() async {


    await PuzzleProgressManager.clearProgress();


  }





  //==================================================
  // حفظ آخر مرحلة لعب
  //==================================================

  static Future<void> saveLastPlayed({

    required String worldId,

    required String levelId,

  }) async {


    await PuzzleProgressManager.saveLastGame(

      "$worldId-$levelId",

    );


  }





  //==================================================
  // جلب آخر مرحلة لعب
  //==================================================

  static Future<String?>

  getLastPlayed() async {


    return await PuzzleProgressManager.getLastGame();


  }





  //==================================================
  // حفظ تلقائي بعد الفوز
  // مستخدم من PuzzleWinScreen
  //==================================================

    static Future<void> autoSavePuzzle({

  required String worldId,

  required int level,

}) async {

  await PuzzleProgressManager.saveLastGame(
    "${worldId}_level_$level",
  );

  await PuzzleProgressManager.saveLastSession(
    DateTime.now(),
  );

}


  //==================================================
  // 🗑 مسح آخر لعبة
  //==================================================

  static Future<void> clearLastPlayed() async {

    await PuzzleProgressManager.saveLastGame("");

  }


}
