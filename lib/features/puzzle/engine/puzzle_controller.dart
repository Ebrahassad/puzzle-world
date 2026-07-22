import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleController {



  final List<PuzzlePiece> pieces;



  PuzzleController({

    required this.pieces,

  });









  // تحريك قطعة

  void movePiece(

      PuzzlePiece piece,

      Offset position,

      ){



    if(piece.placed){

      return;

    }



    piece.position = position;



  }









  // فحص مكان القطعة بعد السحب

  bool checkPiecePosition(

      PuzzlePiece piece,

      double pieceSize,

      ){



    if(piece.placed){

      return true;

    }







    final target = Offset(



      piece.column * pieceSize,



      piece.row * pieceSize,



    );







    final distance =

        (piece.position - target)

            .distance;







    final tolerance =

        pieceSize * 0.35;







    if(distance <= tolerance){



      lockPiece(

        piece,

        pieceSize,

      );



      return true;



    }





    return false;



  }









  // تثبيت القطعة

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









  // تثبيت قطعة بالتلميح

  bool applyHint(

      PuzzlePiece piece,

      double pieceSize,

      ){



    if(piece.placed){

      return false;

    }



    lockPiece(

      piece,

      pieceSize,

    );



    return true;



  }









  // عدد القطع المكتملة

  int get completedPieces {



    return pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;



  }









  // القطع المتبقية

  int get remainingPieces {



    return pieces.length -

        completedPieces;



  }









  // نسبة الإنجاز

  double get progress {



    if(pieces.isEmpty){

      return 0;

    }



    return completedPieces /

        pieces.length;



  }









  // هل انتهت اللعبة

  bool get isCompleted {



    if(pieces.isEmpty){

      return false;

    }



    return pieces.every(

          (piece)=>piece.placed,

    );



  }









  // إعادة ضبط اللعبة

  void reset(){



    for(final piece in pieces){



      piece.reset();



    }



  }









  // إنهاء كامل للتجربة

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