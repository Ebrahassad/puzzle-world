import '../managers/puzzle_progress_manager.dart';



class PuzzleEventService {


  static Future<void> onPuzzleStarted({

    required String worldId,

    required int level,

  }) async {



    await PuzzleProgressManager

        .saveLastGame(

      "$worldId-$level",

    );


  }








  static Future<void> onPuzzleCompleted({

    required String levelId,

    required int stars,

  }) async {



    await PuzzleProgressManager

        .completeLevel(

      levelId,

    );





    await PuzzleProgressManager

        .addStars(

      stars,

    );


  }








  static Future<void> onLevelUnlocked({

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .unlockLevel(

      levelId,

    );


  }








  static Future<void> onHintUsed() async {



    await PuzzleProgressManager

        .addHints(

      -1,

    );


  }








  static Future<void> onRewardReceived({

    required int stars,

  }) async {



    await PuzzleProgressManager

        .addStars(

      stars,

    );


  }








  static Future<void> onGameExit() async {



    await PuzzleProgressManager

        .saveLastSession(

      DateTime.now(),

    );


  }


}