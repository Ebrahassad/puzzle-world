import '../managers/puzzle_progress_manager.dart';



class PuzzleStatisticsService {


  static Future<int> getPlayedCount() async {


    return await PuzzleProgressManager

        .getGamesPlayed();


  }








  static Future<int> getCompletedCount() async {



    return await PuzzleProgressManager

        .getCompletedPuzzleCount();


  }








  static Future<int> getTotalStars() async {



    return await PuzzleProgressManager

        .getTotalStars();


  }








  static Future<int> getTotalMoves() async {



    return await PuzzleProgressManager

        .getTotalMoves();


  }








  static Future<int> getBestTime() async {



    return await PuzzleProgressManager

        .getBestTime();


  }








  static Future<void> addGamePlayed() async {



    await PuzzleProgressManager

        .addGamePlayed();


  }








  static Future<void> addCompletedPuzzle({

    required int stars,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .addCompletedPuzzle(

      stars: stars,

      moves: moves,

      seconds: seconds,

    );


  }








  static Future<Map<String,dynamic>>

  getStatistics() async {



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








  static Future<void>

  resetStatistics() async {



    await PuzzleProgressManager

        .resetStatistics();


  }


}