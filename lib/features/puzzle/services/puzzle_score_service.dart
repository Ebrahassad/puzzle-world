import '../managers/puzzle_progress_manager.dart';



class PuzzleScoreService {


  static int calculateScore({

    required int stars,

    required int moves,

    required int seconds,

    required int difficulty,

  }) {



    int score = 0;





    score += stars * 100;





    score += difficulty * 50;





    if(seconds > 0){


      score += 1000 ~/ seconds;


    }





    score -= moves * 5;





    if(score < 0){

      score = 0;

    }





    return score;


  }








  static Future<int> getHighScore({

    required String levelId,

  }) async {



    return await PuzzleProgressManager

        .getHighScore(

      levelId,

    );


  }








  static Future<void> saveHighScore({

    required String levelId,

    required int score,

  }) async {



    final oldScore =

    await getHighScore(

      levelId: levelId,

    );





    if(score > oldScore){



      await PuzzleProgressManager

          .saveHighScore(

        levelId,

        score,

      );


    }


  }








  static String getRank(

      int score,

      ) {



    if(score >= 3000){

      return "أسطوري 🏆";

    }



    if(score >= 2000){

      return "ممتاز ⭐";

    }



    if(score >= 1000){

      return "جيد 👍";

    }





    return "مبتدئ";


  }


}