import '../managers/puzzle_progress_manager.dart';


class PuzzleStatisticsService {


  const PuzzleStatisticsService._();



  //==================================================
  // 🎮 عدد الألعاب التي تم لعبها
  //==================================================

  static Future<int> getPlayedCount() async {

    return await PuzzleProgressManager.getGamesPlayed();

  }





  //==================================================
  // 🏆 عدد المراحل المكتملة
  //==================================================

  static Future<int> getCompletedCount() async {

    return await PuzzleProgressManager.getCompletedCount();

  }





  //==================================================
  // ⭐ مجموع النجوم
  //==================================================

  static Future<int> getTotalStars() async {

    return await PuzzleProgressManager.getTotalStars();

  }





  //==================================================
  // 🧩 مجموع الحركات
  //==================================================

  static Future<int> getTotalMoves() async {

    return await PuzzleProgressManager.getTotalMoves();

  }





  //==================================================
  // ⏱ أفضل وقت
  //==================================================

  static Future<int> getBestTime() async {

    return await PuzzleProgressManager.getBestTime();

  }





  //==================================================
  // إضافة لعبة مكتملة
  //==================================================

  static Future<void> addCompletedPuzzle({

    required int stars,

    required int moves,

    required int seconds,

  }) async {


    await PuzzleProgressManager.addCompletedPuzzle(

      moves: moves,

      seconds: seconds,

    );


    await PuzzleProgressManager.addStars(

      stars,

    );


  }





  //==================================================
  // الحصول على الإحصائيات
  //==================================================

  static Future<Map<String,dynamic>> getStatistics() async {


    return {


      "played":
      await getPlayedCount(),


      "completed":
      await getCompletedCount(),


      "stars":
      await getTotalStars(),


      "moves":
      await getTotalMoves(),


      "bestTime":
      await getBestTime(),


    };


  }





  //==================================================
  // إعادة ضبط الإحصائيات
  //==================================================

  static Future<void> resetStatistics() async {


    await PuzzleProgressManager.resetAll();


  }



}