import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleController {


  final List<PuzzlePiece> pieces;


  final double boardOffsetY;


  PuzzleController({

    required this.pieces,

    this.boardOffsetY = 0,

  });






  void movePiece(

      PuzzlePiece piece,

      Offset position,

      ){


    if(piece.placed){

      return;

    }


    piece.position = position;


  }









  bool checkPiecePosition(

      PuzzlePiece piece,

      double pieceSize,

      ){



    if(piece.placed){

      return true;

    }






    final target = Offset(



      (piece.column * pieceSize),

      

      (piece.row * pieceSize) + boardOffsetY,



    );






    final pieceCenter = Offset(



      piece.position.dx + (pieceSize / 2),



      piece.position.dy + (pieceSize / 2),



    );






    final targetCenter = Offset(



      target.dx + (pieceSize / 2),



      target.dy + (pieceSize / 2),



    );






    final distance =

    (pieceCenter - targetCenter)

        .distance;







    final tolerance =

        pieceSize * 0.45;








    if(distance <= tolerance){



      lockPiece(

        piece,

        pieceSize,

      );



      return true;



    }





    return false;



  }









  void lockPiece(

      PuzzlePiece piece,

      double pieceSize,

      ){



    piece.position = Offset(



      piece.column * pieceSize,



      (piece.row * pieceSize) + boardOffsetY,



    );





    piece.placed = true;



  }









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









  int get completedPieces =>

      pieces

          .where(

            (piece)=>piece.placed,

          )

          .length;









  int get remainingPieces =>

      pieces.length -

          completedPieces;









  double get progress {



    if(pieces.isEmpty){

      return 0;

    }



    return completedPieces /

        pieces.length;



  }









  bool get isCompleted {



    if(pieces.isEmpty){

      return false;

    }



    return pieces.every(

          (piece)=>piece.placed,

    );



  }









  void reset(){



    for(final piece in pieces){



      piece.reset();



    }



  }









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