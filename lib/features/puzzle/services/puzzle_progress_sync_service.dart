import '../managers/puzzle_progress_manager.dart';



class PuzzleProgressSyncService {


  const PuzzleProgressSyncService._();




  //==================================================
  // 📊 ملخص التقدم
  //==================================================

  static Future<Map<String, dynamic>>

  getProgressSummary() async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    final completed =

    await PuzzleProgressManager

        .getCompletedPuzzleCount();





    final hints =

    await PuzzleProgressManager

        .getHints();





    return {



      "stars": stars,


      "completed": completed,


      "hints": hints,



    };


  }








  //==================================================
  // 🧩 مزامنة مرحلة
  //==================================================

  static Future<void> syncLevel({

    required String levelId,

    required int stars,

  }) async {



    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelId,

    );





    if(!completed){



      await PuzzleProgressManager

          .completeLevel(

        levelId,

      );





      await PuzzleProgressManager

          .addStars(

        stars,

      );


    }


  }








  //==================================================
  // 🌍 مزامنة آخر عالم
  //==================================================

  static Future<void> syncWorld({

    required String worldId,

  }) async {



    await PuzzleProgressManager

        .saveLastWorld(

      worldId,

    );


  }








  //==================================================
  // 🔄 إعادة المزامنة
  //==================================================

  static Future<void> resetSync() async {



    await PuzzleProgressManager

        .resetProgress();


  }


}