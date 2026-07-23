import '../managers/puzzle_progress_manager.dart';



class PuzzleRatingService {


  const PuzzleRatingService._();




  //==================================================
  // ⭐ هل يمكن التقييم
  //==================================================

  static Future<bool> canRate() async {


    final rated =

    await PuzzleProgressManager

        .isRated();





    return !rated;


  }








  //==================================================
  // 💾 حفظ التقييم
  //==================================================

  static Future<void> saveRating({

    required int rating,

  }) async {


    await PuzzleProgressManager

        .saveRating(

      rating,

    );


  }








  //==================================================
  // 📊 جلب التقييم
  //==================================================

  static Future<int> getRating() async {


    return await PuzzleProgressManager

        .getRating();


  }








  //==================================================
  // 💬 رسالة التقييم
  //==================================================

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








  //==================================================
  // 🔄 إعادة التقييم
  //==================================================

  static Future<void> resetRating() async {


    await PuzzleProgressManager

        .resetRating();


  }


}