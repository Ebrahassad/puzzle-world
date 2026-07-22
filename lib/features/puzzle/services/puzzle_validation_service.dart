import '../engine/puzzle_piece.dart';



class PuzzleValidationService {


  static bool isPieceCorrect({

    required PuzzlePiece piece,

    required double pieceSize,

  }) {



    return piece.isCorrect(

      pieceSize,

    );


  }








  static bool isPuzzleCompleted(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.every(

          (piece) => piece.placed,

    );


  }








  static int getPlacedPiecesCount(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.where(

          (piece) => piece.placed,

    ).length;


  }








  static int getRemainingPiecesCount(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.where(

          (piece) => !piece.placed,

    ).length;


  }








  static double getProgress(

      List<PuzzlePiece> pieces,

      ) {



    if(pieces.isEmpty){

      return 0;

    }





    return getPlacedPiecesCount(

      pieces,

    ) / pieces.length;


  }








  static bool canMovePiece(

      PuzzlePiece piece,

      ) {



    return !piece.placed;


  }








  static bool hasInvalidPieces(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.any(

          (piece) => piece.id.isEmpty,

    );


  }


}