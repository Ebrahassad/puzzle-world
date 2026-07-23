import '../managers/puzzle_progress_manager.dart';


class PuzzleEventService {


  const PuzzleEventService._();



  //==================================================
  // بداية المرحلة
  //==================================================

  static Future<void> onPuzzleStarted({

    required String worldId,

    required int level,

  }) async {


    await PuzzleProgressManager.saveLastPuzzle(

      worldId,

      "level_$level",

    );


  }






  //==================================================
  // فتح شاشة المرحلة
  //==================================================

  static Future<void> levelScreenOpened({

    String? worldId,

    int? level,

  }) async {


    if(worldId != null && level != null){


      await PuzzleProgressManager.saveLastPuzzle(

        worldId,

        "level_$level",

      );


    }


  }






  //==================================================
  // إكمال البازل
  //==================================================

  static Future<void> onPuzzleCompleted({

    required String levelId,

    required int stars,

  }) async {


    await PuzzleProgressManager.completeLevel(

      levelId,

    );


  }






  //==================================================
  // يستخدم من PuzzleWinScreen
  //==================================================

  static Future<void> levelCompleted({

    String? worldId,

    int? level,

    required int stars,

    required int moves,

    required int seconds,

  }) async {


    await PuzzleProgressManager.addCompletedPuzzle(

      moves: moves,

      seconds: seconds,

    );



    if(worldId != null && level != null){


      await PuzzleProgressManager.saveLastPuzzle(

        worldId,

        "level_$level",

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
  // استخدام تلميح
  //==================================================

  static Future<void> onHintUsed() async {


    await PuzzleProgressManager.useHint();


  }






  //==================================================
  // مكافأة نجوم
  //==================================================

  static Future<void> onRewardReceived({

    required int stars,

  }) async {


    await PuzzleProgressManager.addStars(

      stars,

    );


  }






  //==================================================
  // مضاعفة المكافأة
  //==================================================

  static Future<void> rewardDoubled({

    required int coins,

    required int gems,

  }) async {


    await PuzzleProgressManager.addCoins(

      coins,

    );



    if(gems > 0){


      await PuzzleProgressManager.addGems(

        gems,

      );


    }


  }






  //==================================================
  // خروج
  //==================================================

  static Future<void> onGameExit() async {


    // الحفظ يتم عن طريق PuzzleProgressManager

  }


}