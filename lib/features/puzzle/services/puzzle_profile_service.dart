import '../managers/puzzle_progress_manager.dart';



class PuzzleProfileService {


  static Future<Map<String, dynamic>>

  getProfile() async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    final completed =

    await PuzzleProgressManager

        .getCompletedPuzzleCount();





    final hints =

    await PuzzleProgressManager

        .getHints();





    final games =

    await PuzzleProgressManager

        .getGamesPlayed();





    return {



      "stars": stars,


      "completed": completed,


      "hints": hints,


      "games": games,



    };


  }








  static Future<void> updateName({

    required String name,

  }) async {



    await PuzzleProgressManager

        .savePlayerName(

      name,

    );


  }








  static Future<String> getName() async {



    return await PuzzleProgressManager

        .getPlayerName();


  }








  static Future<void> resetProfile() async {



    await PuzzleProgressManager

        .resetProgress();


  }


}