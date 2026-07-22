import '../managers/puzzle_progress_manager.dart';


class PuzzleEventService {


  //==================================================
  // بداية المرحلة
  //==================================================

  static Future<void> onPuzzleStarted({

    required String worldId,

    required int level,

  }) async {


    await PuzzleProgressManager.saveLastGame(

      "$worldId-$level",

    );


  }




  // يستخدم عند فتح شاشة الفوز

  static Future<void> levelScreenOpened({

    String? worldId,

    int? level,

  }) async {


    if(worldId != null && level != null){

      await PuzzleProgressManager.saveLastGame(

        "$worldId-$level",

      );

    }


  }





  //==================================================
  // إكمال المرحلة
  //==================================================

  static Future<void> onPuzzleCompleted({

    required String levelId,

    required int stars,

  }) async {



    await PuzzleProgressManager.completeLevel(

      levelId,

    );



    await PuzzleProgressManager.addStars(

      stars,

    );


  }





  // يستخدم من WinScreen

  static Future<void> levelCompleted({

    String? worldId,

    int? level,

    required int stars,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager.addCompletedPuzzle(

      stars: stars,

      moves: moves,

      seconds: seconds,

    );



    if(worldId != null && level != null){

      await PuzzleProgressManager.saveLastGame(

        "$worldId-$level",

      );

    }


  }






  //==================================================
  // فتح مرحلة
  //==================================================

  static Future<void> onLevelUnlocked({

    required String levelId,

  }) async {


    await PuzzleProgressManager.unlockLevel(

      levelId,

    );


  }






  //==================================================
  // التلميحات
  //==================================================

  static Future<void> onHintUsed() async {


    await PuzzleProgressManager.addHints(

      -1,

    );


  }






  //==================================================
  // مكافأة
  //==================================================

  static Future<void> onRewardReceived({

    required int stars,

  }) async {


    await PuzzleProgressManager.addStars(

      stars,

    );


  }






  // يستخدم عند مضاعفة المكافأة

  static Future<void> rewardDoubled({

    String? worldId,

    int? level,

    required int coins,

    required int gems,

  }) async {


    // نحفظ آخر جلسة فقط

    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


  }






  //==================================================
  // خروج من اللعبة
  //==================================================

  static Future<void> onGameExit() async {


    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


  }


}