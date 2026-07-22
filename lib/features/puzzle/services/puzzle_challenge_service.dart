import '../managers/puzzle_progress_manager.dart';



class PuzzleChallengeService {


  static Future<bool> hasDailyChallenge() async {



    final date =

    await PuzzleProgressManager

        .getDailyChallengeDate();





    if(date == null){

      return true;

    }





    return DateTime.now()

        .difference(

      date,

    )

        .inDays >= 1;


  }








  static Future<void> startChallenge({

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .saveDailyChallenge(

      levelId,

      DateTime.now(),

    );


  }








  static Future<Map<String,dynamic>>

  getChallenge() async {



    final levelId =

    await PuzzleProgressManager

        .getDailyChallengeLevel();





    final date =

    await PuzzleProgressManager

        .getDailyChallengeDate();





    return {



      "levelId": levelId,


      "date": date,



    };


  }








  static Future<void> completeChallenge({

    required int stars,

    required int score,

  }) async {



    await PuzzleProgressManager

        .addStars(

      stars,

    );





    await PuzzleProgressManager

        .addChallengeScore(

      score,

    );


  }








  static Future<int> getChallengeScore() async {



    return await PuzzleProgressManager

        .getChallengeScore();


  }


}