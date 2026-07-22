import '../engine/puzzle_piece.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleHintService {


  static Future<int> getHints() async {


    return await PuzzleProgressManager

        .getHints();


  }








  static Future<void> addHints(

      int amount,

      ) async {



    await PuzzleProgressManager

        .addHints(

      amount,

    );


  }








  static Future<bool> useHint() async {



    return await PuzzleProgressManager

        .useHint();


  }








  static Future<bool> hasHints() async {



    final hints =

    await getHints();





    return hints > 0;


  }








  static PuzzlePiece? findHintPiece(

      List<PuzzlePiece> pieces,

      ) {



    final available = pieces.where(

          (piece) => !piece.placed,

    ).toList();





    if(available.isEmpty){

      return null;

    }





    available.shuffle();





    return available.first;


  }








  static int remainingPieces(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.where(

          (piece) => !piece.placed,

    ).length;


  }








  static bool isPuzzleCompleted(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.every(

          (piece) => piece.placed,

    );


  }

}