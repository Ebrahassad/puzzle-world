import '../managers/puzzle_progress_manager.dart';



class PuzzleSessionService {


  static DateTime? _startTime;


  static String? _worldId;


  static int? _level;








  static void startSession({

    required String worldId,

    required int level,

  }) {



    _worldId = worldId;


    _level = level;


    _startTime = DateTime.now();


  }








  static Future<void> endSession({

    int moves = 0,

  }) async {



    if(_startTime == null){

      return;

    }





    final duration =

    DateTime.now()

        .difference(

      _startTime!,

    );





    await PuzzleProgressManager

        .addPlayTime(

      duration.inSeconds,

    );





    await PuzzleProgressManager

        .addTotalMoves(

      moves,

    );





    _startTime = null;


    _worldId = null;


    _level = null;


  }








  static bool isActive(){



    return _startTime != null;


  }








  static String? getWorld(){



    return _worldId;


  }








  static int? getLevel(){



    return _level;


  }








  static Duration getDuration(){



    if(_startTime == null){

      return Duration.zero;

    }





    return DateTime.now()

        .difference(

      _startTime!,

    );


  }


}