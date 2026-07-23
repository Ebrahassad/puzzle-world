import '../engine/puzzle_piece.dart';



class PuzzleValidationService {


  const PuzzleValidationService._();




  //==================================================
  // 🧩 فحص صحة القطعة
  //==================================================

  static bool isPieceCorrect({

    required PuzzlePiece piece,

    required double pieceSize,

  }) {


    return piece.isCorrect(

      pieceSize,

    );


  }








  //==================================================
  // 🏆 هل البازل مكتمل
  //==================================================

  static bool isPuzzleCompleted(

      List<PuzzlePiece> pieces,

      ) {


    return pieces.every(

          (piece) => piece.placed,

    );


  }








  //==================================================
  // ✅ عدد القطع الصحيحة
  //==================================================

  static int getPlacedPiecesCount(

      List<PuzzlePiece> pieces,

      ) {


    return pieces.where(

          (piece) => piece.placed,

    ).length;


  }








  //==================================================
  // ⏳ القطع المتبقية
  //==================================================

  static int getRemainingPiecesCount(

      List<PuzzlePiece> pieces,

      ) {


    return pieces.where(

          (piece) => !piece.placed,

    ).length;


  }








  //==================================================
  // 📊 نسبة الإنجاز
  //==================================================

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








  //==================================================
  // 🚚 هل يمكن تحريك القطعة
  //==================================================

  static bool canMovePiece(

      PuzzlePiece piece,

      ) {


    return !piece.placed;


  }








  //==================================================
  // ⚠️ وجود قطع غير صالحة
  //==================================================

  static bool hasInvalidPieces(

      List<PuzzlePiece> pieces,

      ) {


    return pieces.any(

          (piece) => piece.id.isEmpty,

    );


  }


}