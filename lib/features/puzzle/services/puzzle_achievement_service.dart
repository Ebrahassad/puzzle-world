import '../managers/puzzle_progress_manager.dart';


class PuzzleAchievementService {


  //==================================================
  // جلب الإنجازات
  //==================================================

  static Future<List<String>>

  getAchievements() async {


    final result = <String>[];



    final stars =
        await PuzzleProgressManager
            .getTotalStars();




    final completed =
        await PuzzleProgressManager
            .getCompletedPuzzleCount();




    final hints =
        await PuzzleProgressManager
            .getHints();




    if(stars >= 50){

      result.add(
        "⭐ جامع النجوم",
      );

    }




    if(stars >= 200){

      result.add(
        "🌟 سيد النجوم",
      );

    }




    if(completed >= 10){

      result.add(
        "🧩 محترف البازل",
      );

    }




    if(completed >= 50){

      result.add(
        "🏆 أسطورة البازل",
      );

    }




    if(hints >= 10){

      result.add(
        "💡 خبير المساعدة",
      );

    }




    return result;


  }







  //==================================================
  // فحص إنجاز معين
  //==================================================

  static Future<bool>

  hasAchievement(

      String name,

      ) async {


    final achievements =
        await getAchievements();




    return achievements.contains(

      name,

    );


  }







  //==================================================
  // عدد الإنجازات
  //==================================================

  static Future<int>

  getAchievementCount() async {


    final achievements =
        await getAchievements();




    return achievements.length;


  }







  //==================================================
  // يستخدم بعد إكمال المرحلة
  // من PuzzleWinScreen
  //==================================================

  static Future<void>

  checkPuzzleAchievements({

    String? worldId,

    int? level,

    required dynamic result,

  }) async {


    // الإنجازات تعتمد على الإحصائيات الحالية
    // ويتم حسابها تلقائياً من getAchievements()

    await getAchievements();


  }


}