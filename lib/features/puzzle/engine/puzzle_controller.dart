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



      piece.column * pieceSize,



      (piece.row * pieceSize) + boardOffsetY,



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









  int get completedPieces {



    return pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;



  }









  int get remainingPieces {



    return pieces.length -

        completedPieces;



  }









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