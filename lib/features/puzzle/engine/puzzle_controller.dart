import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzleController {


  final List<PuzzlePiece> pieces;



  PuzzleController({

    required this.pieces,

  });





  // =========================
  // تحريك قطعة
  // =========================


  void movePiece(

      PuzzlePiece piece,

      Offset position,

      ){

    if(piece.placed){

      return;

    }


    piece.position = position;


  }







  // =========================
  // فحص مكان القطعة
  // =========================


  bool checkPiecePosition(

      PuzzlePiece piece,

      double pieceSize,

      ){


    if(piece.placed){

      return true;

    }




    final correctX =

        piece.column * pieceSize;



    final correctY =

        piece.row * pieceSize;





    final dx =

    (piece.position.dx - correctX).abs();



    final dy =

    (piece.position.dy - correctY).abs();






    final tolerance =

        pieceSize * 0.35;







    if(dx <= tolerance && dy <= tolerance){



      lockPiece(

        piece,

        pieceSize,

      );



      return true;

    }





    return false;


  }









  // =========================
  // تثبيت القطعة
  // =========================


  void lockPiece(

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
  // تثبيت بالتلميح
  // =========================


  void applyHint(

      PuzzlePiece piece,

      double pieceSize,

      ){



    if(piece.placed){

      return;

    }



    piece.placeHint(

      pieceSize,

    );


  }









  // =========================
  // عدد القطع المكتملة
  // =========================


  int get completedPieces {



    return pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;


  }









  // =========================
  // القطع المتبقية
  // =========================


  int get remainingPieces {



    return pieces.length -

        completedPieces;


  }









  // =========================
  // نسبة الإنجاز
  // =========================


  double get progress {



    if(pieces.isEmpty){

      return 0;

    }



    return completedPieces /

        pieces.length;


  }









  // =========================
  // هل اكتملت اللعبة؟
  // =========================


  bool get isCompleted {



    return pieces.every(

          (piece)=>piece.placed,

    );


  }









  // =========================
  // إعادة اللعبة
  // =========================


  void reset(){



    for(final piece in pieces){



      piece.reset();



    }



  }









  // =========================
  // إنهاء تلقائي (للتجربة أو التلميحات)
  // =========================


  void completeAll(

      double pieceSize,

      ){



    for(final piece in pieces){



      lockPiece(

        piece,

        pieceSize,

      );



    }


  }



}