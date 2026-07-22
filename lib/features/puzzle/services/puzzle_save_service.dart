import '../engine/puzzle_piece.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleSaveService {


  static Future<void> saveGame({

    required String puzzleId,

    required String levelId,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .saveProgress(

      puzzleId: puzzleId,

      levelId: levelId,

      pieces: pieces,

      moves: moves,

      seconds: seconds,

    );


  }








  static Future<Map<String,dynamic>?>

  loadGame() async {



    return await PuzzleProgressManager

        .loadProgress();


  }








  static Future<bool> hasSavedGame({

    required String puzzleId,

    required String levelId,

  }) async {



    final saved =

    await loadGame();





    if(saved == null){

      return false;

    }





    return saved["puzzleId"] == puzzleId &&

        saved["levelId"] == levelId;


  }








  static Future<void> clearGame() async {



    await PuzzleProgressManager

        .clearProgress();


  }








  static Future<void> saveLastPlayed({

    required String worldId,

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .saveLastPuzzle(

      worldId,

      levelId,

    );


  }








  static Future<Map<String,dynamic>?>

  getLastPlayed() async {



    return await PuzzleProgressManager

        .getLastPuzzle();


  }

}