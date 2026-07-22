import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleController {



  final List<PuzzlePiece> pieces;



  PuzzleController({

    required this.pieces,

  });







  // =========================
  // فحص وضع القطعة بعد السحب
  // =========================


  void checkPiecePosition(

      PuzzlePiece piece,

      double pieceSize,

      ) {



    final correctX =

        piece.column * pieceSize;



    final correctY =

        piece.row * pieceSize;





    final distance =

    Offset(

      piece.position.dx,

      piece.position.dy,

    )

        .distance;



    final target = Offset(

      correctX,

      correctY,

    );



    final difference =

    (Offset(

      piece.position.dx,

      piece.position.dy,

    ) -

        target)

        .distance;







    // السماح بهامش خطأ أثناء السحب

    if(difference < pieceSize / 2){



      piece.position = target;



      piece.placed = true;



    }else{



      piece.placed = false;



    }



  }









  // =========================
  // فحص اكتمال اللعبة
  // =========================


  bool get isCompleted {



    if(pieces.isEmpty){

      return false;

    }





    return pieces.every(

          (piece)=>piece.placed,

    );



  }









  // =========================
  // عدد القطع الصحيحة
  // =========================


  int get completedPieces {



    return pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;



  }









  // =========================
  // إعادة ضبط اللعبة
  // =========================


  void reset(){



    for(final piece in pieces){



      piece.position = Offset.zero;



      piece.placed = false;



    }



  }









  // =========================
  // وضع قطعة بواسطة التلميح
  // =========================


  void placePieceByHint(

      PuzzlePiece piece,

      double pieceSize,

      ){



    piece.position = Offset(

      piece.column * pieceSize,

      piece.row * pieceSize,

    );



    piece.placed = true;



  }









  // =========================
  // هل القطعة في مكانها؟
  // =========================


  bool isPieceCorrect(

      PuzzlePiece piece,

      double pieceSize,

      ){



    final target = Offset(

      piece.column * pieceSize,

      piece.row * pieceSize,

    );



    return

      (piece.position - target)

          .distance < pieceSize / 2;



  }





}