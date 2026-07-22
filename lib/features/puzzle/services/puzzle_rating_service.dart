import '../managers/puzzle_progress_manager.dart';



class PuzzleRatingService {


  static Future<bool> canRate() async {



    final rated =

    await PuzzleProgressManager

        .isRated();





    return !rated;


  }








  static Future<void> saveRating({

    required int rating,

  }) async {



    await PuzzleProgressManager

        .saveRating(

      rating,

    );


  }








  static Future<int> getRating() async {



    return await PuzzleProgressManager

        .getRating();


  }








  static String getRatingMessage(

      int rating,

      ) {



    switch(rating){



      case 5:

        return "رائع جداً! ⭐⭐⭐⭐⭐";



      case 4:

        return "ممتاز! ⭐⭐⭐⭐";



      case 3:

        return "جيد 👍⭐⭐⭐";



      case 2:

        return "سنحسن اللعبة أكثر";



      case 1:

        return "شكراً لملاحظتك";



      default:

        return "";

    }


  }








  static Future<void> resetRating() async {



    await PuzzleProgressManager

        .resetRating();


  }


}