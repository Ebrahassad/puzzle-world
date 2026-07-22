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

      "${worldId}_level_$level",

    );


  }





  //==================================================
  // فتح شاشة الفوز
  //==================================================

  static Future<void> levelScreenOpened({

    String? worldId,

    int? level,

  }) async {


    if(worldId != null && level != null){


      await PuzzleProgressManager.saveLastGame(

        "${worldId}_level_$level",

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

      stars: stars,

      moves: moves,

      seconds: seconds,

    );



    if(worldId != null && level != null){


      await PuzzleProgressManager.saveLastGame(

        "${worldId}_level_$level",

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
  // مكافأة
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
  // خروج من اللعبة
  //==================================================

  static Future<void> onGameExit() async {


    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


  }


}