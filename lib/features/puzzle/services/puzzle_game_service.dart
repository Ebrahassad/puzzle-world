import '../engine/puzzle_piece.dart';

import '../models/game_result_model.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/puzzle_statistics_service.dart';



class PuzzleGameService {


  static Future<void> startGame({

    required String worldId,

    required int level,

  }) async {



    await PuzzleProgressManager

        .saveLastGame(

      "$worldId-$level",

    );





    await PuzzleStatisticsService

        .addGamePlayed();


  }








  static Future<bool> checkCompleted(

      List<PuzzlePiece> pieces,

      ) async {



    return pieces.every(

          (piece) => piece.placed,

    );


  }








  static Future<GameResultModel>

  finishGame({

    required String worldId,

    required int level,

    required int stars,

    required int moves,

    required Duration time,

  }) async {



    final result = GameResultModel(

      stars: stars,

      moves: moves,

      time: time,

    );





    await PuzzleStatisticsService

        .addCompletedPuzzle(

      stars: stars,

      moves: moves,

      seconds: time.inSeconds,

    );





    await PuzzleProgressManager

        .completeLevel(

      "${worldId}_level_$level",

    );





    return result;


  }








  static int calculateStars({

    required int moves,

    required int seconds,

    required int difficulty,

  }) {



    int stars = 1;





    if(moves <= difficulty * 15){

      stars++;

    }





    if(seconds <= difficulty * 60){

      stars++;

    }





    if(stars > 3){

      stars = 3;

    }





    return stars;


  }








  static bool isCorrectPlacement({

    required PuzzlePiece piece,

    required double pieceSize,

  }) {



    return piece.isCorrect(

      pieceSize,

    );


  }








  static Future<void> saveCurrentState({

    required String worldId,

    required int level,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {



    await PuzzleProgressManager

        .saveProgress(

      puzzleId: worldId,

      levelId: "$level",

      pieces: pieces,

      moves: moves,

      seconds: seconds,

    );


  }








  static Future<void> clearCurrentState() async {



    await PuzzleProgressManager

        .clearProgress();


  }


}