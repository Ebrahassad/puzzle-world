import '../managers/puzzle_progress_manager.dart';



class PuzzlePurchaseService {


  const PuzzlePurchaseService._();




  //==================================================
  // 💡 شراء تلميح
  //==================================================

  static Future<bool> buyHint({

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager.getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager.addStars(

      -price,

    );





    await PuzzleProgressManager.addHints(

      1,

    );





    return true;


  }








  //==================================================
  // 🔓 شراء فتح مرحلة
  //==================================================

  static Future<bool> buyUnlock({

    required String levelId,

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager.getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager.addStars(

      -price,

    );





    await PuzzleProgressManager.unlockLevel(

      levelId,

    );





    return true;


  }








  //==================================================
  // ❤️ شراء حياة إضافية
  //==================================================

  static Future<bool> buyExtraLife({

    required int price,

  }) async {



    final stars =

    await PuzzleProgressManager.getTotalStars();





    if(stars < price){

      return false;

    }





    await PuzzleProgressManager.addStars(

      -price,

    );





    await PuzzleProgressManager.addLives(

      1,

    );





    return true;


  }








  //==================================================
  // ⭐ الرصيد الحالي
  //==================================================

  static Future<int> getBalance() async {


    return await PuzzleProgressManager.getTotalStars();


  }


}