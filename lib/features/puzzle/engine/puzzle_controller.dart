import 'package:flutter/material.dart';

import 'puzzle_piece.dart';





class PuzzleController {



  final List<PuzzlePiece> pieces;




  PuzzlePiece?

      draggingPiece;






  PuzzleController({

    required this.pieces,

  });






  //==================================================
  // بداية السحب
  //==================================================

  void startDragging(

    PuzzlePiece piece,

  ) {


    if(piece.placed) return;



    draggingPiece = piece;


  }







  //==================================================
  // نهاية السحب
  //==================================================

  void endDragging(

    PuzzlePiece piece,

  ) {


    if(draggingPiece == piece) {


      draggingPiece = null;


    }


  }







  //==================================================
  // فحص مكان القطعة
  //==================================================

  bool checkPiecePosition(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    if(piece.placed) {


      return true;


    }





    final target =

        piece.correctOffset(

          pieceSize,

        );





    final distance =

        (piece.position - target)

            .distance;






    final tolerance =

        pieceSize * 0.35;





    if(distance <= tolerance) {


      lockPiece(

        piece,

        pieceSize,

      );



      return true;


    }



    return false;


  }


  //==================================================
  // تثبيت القطعة
  //==================================================

  void lockPiece(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    piece.lock(

      pieceSize,

    );


  }







  //==================================================
  // فك التثبيت
  //==================================================

  void unlockPiece(

    PuzzlePiece piece,

  ) {


    piece.unlock();


  }







  //==================================================
  // عدد القطع المكتملة
  //==================================================

  int get completedPieces {


    return pieces

        .where(

          (piece) => piece.placed,

        )

        .length;


  }







  //==================================================
  // القطع المتبقية
  //==================================================

  int get remainingPieces {


    return pieces.length -

        completedPieces;


  }







  //==================================================
  // نسبة الإنجاز
  //==================================================

  double get progress {


    if(pieces.isEmpty) {


      return 0;


    }



    return completedPieces /

        pieces.length;


  }







  //==================================================
  // هل اكتملت اللعبة
  //==================================================

  bool get isCompleted {


    if(pieces.isEmpty) {


      return false;


    }



    return pieces.every(

      (piece) => piece.placed,

    );


  }







  //==================================================
  // إعادة اللعبة
  //==================================================

  void reset() {


    for(final piece in pieces) {


      piece.reset();


    }



    draggingPiece = null;


  }







  //==================================================
  // البحث عن قطعة
  //==================================================

  PuzzlePiece?

      findPiece(

        String id,

      ) {



    for(final piece in pieces) {


      if(piece.id == id) {


        return piece;


      }


    }



    return null;


  }



}