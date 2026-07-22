import '../managers/puzzle_progress_manager.dart';



class PuzzleLeaderboardService {


  static Future<List<Map<String, dynamic>>>

  getLeaderboard() async {



    return await PuzzleProgressManager

        .getLeaderboard();


  }








  static Future<void> submitScore({

    required String playerName,

    required int score,

    required int stars,

  }) async {



    final data = {



      "name": playerName,


      "score": score,


      "stars": stars,


      "date":

      DateTime.now()

          .toIso8601String(),



    };





    await PuzzleProgressManager

        .saveLeaderboardScore(

      data,

    );


  }








  static Future<int> getPlayerRank({

    required int score,

  }) async {



    final leaderboard =

    await getLeaderboard();





    int rank = 1;





    for(final player in leaderboard){



      if((player["score"] ?? 0) > score){


        rank++;


      }


    }





    return rank;


  }








  static List<Map<String, dynamic>>

  sortScores(

      List<Map<String, dynamic>> scores,

      ) {



    scores.sort(

          (a,b) =>

          (b["score"] ?? 0)

              .compareTo(

            a["score"] ?? 0,

          ),

    );





    return scores;


  }


}