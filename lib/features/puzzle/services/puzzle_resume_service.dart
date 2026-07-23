import '../managers/puzzle_progress_manager.dart';



class PuzzleResumeService {


  const PuzzleResumeService._();




  //==================================================
  // ▶️ هل يوجد لعبة مستأنفة
  //==================================================

  static Future<bool> hasResumeGame() async {


    final data =

    await PuzzleProgressManager

        .getLastPuzzle();





    return data != null;


  }








  //==================================================
  // 📂 بيانات الاستكمال
  //==================================================

  static Future<Map<String,String>?>

  getResumeData() async {


    return await PuzzleProgressManager

        .getLastPuzzle();


  }








  //==================================================
  // 💾 حفظ الاستكمال
  //==================================================

  static Future<void> saveResumeGame({

    required String worldId,

    required String levelId,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .saveLastPuzzle(

      worldId,

      levelId,

    );





    await PuzzleProgressManager

        .saveGameState(

      worldId: worldId,

      levelId: levelId,

      moves: moves,

      seconds: seconds,

    );


  }








  //==================================================
  // 🗑 مسح الاستكمال
  //==================================================

  static Future<void> clearResumeGame() async {


    await PuzzleProgressManager

        .clearLastPuzzle();





    await PuzzleProgressManager

        .clearProgress();


  }








  //==================================================
  // 🌍 عالم الاستكمال
  //==================================================

  static Future<String?>

  getResumeWorld() async {


    final data =

    await getResumeData();





    return data?["worldId"];


  }








  //==================================================
  // 🧩 مرحلة الاستكمال
  //==================================================

  static Future<String?>

  getResumeLevel() async {


    final data =

    await getResumeData();





    return data?["levelId"];


  }


}