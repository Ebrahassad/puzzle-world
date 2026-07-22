import '../managers/puzzle_progress_manager.dart';



class PuzzleLevelStatisticsService {


  static Future<Map<String, dynamic>>

  getLevelStatistics({

    required String levelId,

  }) async {



    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelId,

    );





    final score =

    await PuzzleProgressManager

        .getHighScore(

      levelId,

    );





    final stars =

    await PuzzleProgressManager

        .getLevelStars(

      levelId,

    );





    final moves =

    await PuzzleProgressManager

        .getLevelMoves(

      levelId,

    );





    final time =

    await PuzzleProgressManager

        .getLevelTime(

      levelId,

    );





    return {



      "completed": completed,


      "score": score,


      "stars": stars,


      "moves": moves,


      "time": time,



    };


  }








  static Future<void> saveStatistics({

    required String levelId,

    required int score,

    required int stars,

    required int moves,

    required int time,

  }) async {



    await PuzzleProgressManager

        .saveHighScore(

      levelId,

      score,

    );





    await PuzzleProgressManager

        .saveLevelStars(

      levelId,

      stars,

    );





    await PuzzleProgressManager

        .saveLevelMoves(

      levelId,

      moves,

    );





    await PuzzleProgressManager

        .saveLevelTime(

      levelId,

      time,

    );


  }








  static Future<bool> isPerfect({

    required String levelId,

  }) async {



    final stars =

    await PuzzleProgressManager

        .getLevelStars(

      levelId,

    );





    return stars >= 3;


  }


}