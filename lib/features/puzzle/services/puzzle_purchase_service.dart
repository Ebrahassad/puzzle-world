import '../managers/puzzle_progress_manager.dart';



class PuzzlePurchaseService {


  static Future<bool> buyHint({

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager

        .addStars(

      -price,

    );





    await PuzzleProgressManager

        .addHints(

      1,

    );





    return true;


  }








  static Future<bool> buyUnlock({

    required String levelId,

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager

        .addStars(

      -price,

    );





    await PuzzleProgressManager

        .unlockLevel(

      levelId,

    );





    return true;


  }








  static Future<bool> buyExtraLife({

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager

        .addStars(

      -price,

    );





    await PuzzleProgressManager

        .addLives(

      1,

    );





    return true;


  }








  static Future<int> getBalance() async {



    return await PuzzleProgressManager

        .getTotalStars();


  }


}