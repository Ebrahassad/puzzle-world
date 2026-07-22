import '../managers/puzzle_progress_manager.dart';



class PuzzleAnalyticsService {


  static Future<void> levelStarted({

    required String worldId,

    required int level,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "level_started",

      {

        "worldId": worldId,

        "level": level,

      },

    );


  }








  static Future<void> levelCompleted({

    required String worldId,

    required int level,

    required int stars,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "level_completed",

      {

        "worldId": worldId,

        "level": level,

        "stars": stars,

        "moves": moves,

        "seconds": seconds,

      },

    );


  }








  static Future<void> worldOpened({

    required String worldId,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "world_opened",

      {

        "worldId": worldId,

      },

    );


  }








  static Future<void> rewardClaimed({

    required String rewardType,

    required int amount,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "reward_claimed",

      {

        "type": rewardType,

        "amount": amount,

      },

    );


  }








  static Future<void> adWatched({

    required String adType,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "ad_watched",

      {

        "type": adType,

      },

    );


  }








  static Future<void> hintUsed({

    required String worldId,

    required int level,

  }) async {



    await PuzzleProgressManager

        .sendAnalytics(

      "hint_used",

      {

        "worldId": worldId,

        "level": level,

      },

    );


  }








  static Future<void> resetAnalytics() async {



    await PuzzleProgressManager

        .clearAnalytics();


  }


}