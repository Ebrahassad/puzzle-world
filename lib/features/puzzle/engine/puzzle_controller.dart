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








  // فحص هل القطعة في مكانها

  bool checkPiecePosition(

      PuzzlePiece piece,

      double tolerance,

      ){



    if(piece.placed){

      return true;

    }





    final correctX =

    piece.column * tolerance;



    final correctY =

    piece.row * tolerance;







    final distanceX =

    (piece.position.dx - correctX).abs();



    final distanceY =

    (piece.position.dy - correctY).abs();







    if(distanceX < tolerance / 2 &&

        distanceY < tolerance / 2){



      piece.position = Offset(



        correctX,

        correctY,



      );



      piece.placed = true;



      return true;



    }





    return false;



  }









  // عدد القطع المكتملة

  int get completedPieces {



    return pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;



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



    return pieces.every(

          (piece)=>piece.placed,

    );



  }








  // إعادة ضبط اللعبة

  void reset(){



    for(final piece in pieces){



      piece.placed = false;



    }



  }








  // تثبيت كل القطع

  void completeAll(){



    for(final piece in pieces){



      piece.placed = true;



      piece.position = Offset(



        piece.column *

            (pieces.first.sourceRect.width),



        piece.row *

            (pieces.first.sourceRect.height),



      );



    }



  }



}