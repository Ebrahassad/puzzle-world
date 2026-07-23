import '../managers/puzzle_progress_manager.dart';



class PuzzleProfileService {


  const PuzzleProfileService._();




  //==================================================
  // 👤 بيانات الملف الشخصي
  //==================================================

  static Future<Map<String, dynamic>> getProfile() async {



    final stars =

    await PuzzleProgressManager.getTotalStars();





    final completed =

    await PuzzleProgressManager.getCompletedPuzzleCount();





    final hints =

    await PuzzleProgressManager.getHints();





    final games =

    await PuzzleProgressManager.getGamesPlayed();





    return {


      "stars": stars,


      "completed": completed,


      "hints": hints,


      "games": games,


    };


  }








  //==================================================
  // ✏️ تحديث الاسم
  //==================================================

  static Future<void> updateName({

    required String name,

  }) async {


    await PuzzleProgressManager.savePlayerName(

      name,

    );


  }








  //==================================================
  // 🏷️ جلب الاسم
  //==================================================

  static Future<String> getName() async {


    return await PuzzleProgressManager.getPlayerName();


  }








  //==================================================
  // 🔄 إعادة ضبط الملف
  //==================================================

  static Future<void> resetProfile() async {


    await PuzzleProgressManager.resetProgress();


  }


}