import '../managers/puzzle_progress_manager.dart';



class PuzzleStateService {


  static Future<void> saveState({

    required String levelId,

    required Map<String,dynamic> state,

  }) async {



    await PuzzleProgressManager

        .savePuzzleState(

      levelId,

      state,

    );


  }








  static Future<Map<String,dynamic>?>

  getState({

    required String levelId,

  }) async {



    return await PuzzleProgressManager

        .getPuzzleState(

      levelId,

    );


  }








  static Future<void> clearState({

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .clearPuzzleState(

      levelId,

    );


  }








  static Future<void> saveCurrentPosition({

    required String levelId,

    required List<Map<String,dynamic>> pieces,

    required int moves,

    required int seconds,

  }) async {



    await saveState(

      levelId: levelId,

      state: {



        "pieces": pieces,


        "moves": moves,


        "seconds": seconds,



      },

    );


  }








  static Future<Map<String,dynamic>?>

  restoreCurrentPosition({

    required String levelId,

  }) async {



    return await getState(

      levelId: levelId,

    );


  }








  static Future<bool> hasSavedState({

    required String levelId,

  }) async {



    final state =

    await getState(

      levelId: levelId,

    );





    return state != null;


  }


}