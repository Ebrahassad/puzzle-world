import '../managers/puzzle_progress_manager.dart';



class PuzzleHistoryService {


  static Future<List<Map<String,dynamic>>>

  getHistory() async {



    return await PuzzleProgressManager

        .getPuzzleHistory();


  }








  static Future<void> addHistory({

    required String worldId,

    required int level,

    required int stars,

    required int score,

  }) async {



    final history =

    await getHistory();





    history.add(



      {



        "worldId": worldId,


        "level": level,


        "stars": stars,


        "score": score,


        "date":

        DateTime.now()

            .toIso8601String(),



      }



    );





    await PuzzleProgressManager

        .savePuzzleHistory(

      history,

    );


  }








  static Future<void> clearHistory() async {



    await PuzzleProgressManager

        .clearPuzzleHistory();


  }








  static Future<int> getPlayedCount() async {



    final history =

    await getHistory();





    return history.length;


  }








  static Future<Map<String,dynamic>?>

  getLastPlayed() async {



    final history =

    await getHistory();





    if(history.isEmpty){

      return null;

    }





    return history.last;


  }


}