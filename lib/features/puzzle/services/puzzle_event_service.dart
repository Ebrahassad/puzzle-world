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

      "$worldId-level_$level",

    );


    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

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

        "$worldId-level_$level",

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
  // إكمال المرحلة من WinScreen
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

        "$worldId-level_$level",

      );


    }





    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


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


    await PuzzleProgressManager.addHints(

      -1,

    );


  }






  //==================================================
  // استلام مكافأة
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

    String? worldId,

    int? level,

    required int coins,

    required int gems,

  }) async {


    await PuzzleProgressManager.addReward(

      coins: coins,

      gems: gems,

    );



    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


    if(worldId != null && level != null){


      await PuzzleProgressManager.saveLastGame(

        "$worldId-level_$level",

      );


    }


  }






  //==================================================
  // الخروج من اللعبة
  //==================================================

  static Future<void> onGameExit() async {


    await PuzzleProgressManager.saveLastSession(

      DateTime.now(),

    );


  }


}