import '../managers/puzzle_progress_manager.dart';



class PuzzleResumeService {


  static Future<bool> hasResumeGame() async {


    final data =

    await PuzzleProgressManager

        .getLastPuzzle();





    return data != null;


  }








  static Future<Map<String, dynamic>?>

  getResumeData() async {



    return await PuzzleProgressManager

        .getLastPuzzle();


  }








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








  static Future<void> clearResumeGame() async {



    await PuzzleProgressManager

        .clearLastPuzzle();


    await PuzzleProgressManager

        .clearProgress();


  }








  static Future<String?>

  getResumeWorld() async {



    final data =

    await getResumeData();





    return data?["worldId"]?.toString();


  }








  static Future<String?>

  getResumeLevel() async {



    final data =

    await getResumeData();





    return data?["levelId"]?.toString();


  }


}