import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleController {



  final List<PuzzlePiece> pieces;



  PuzzleController({

    required this.pieces,

  });





  void movePiece(

      int id,

      Offset newPosition,

      ) {



    final piece = pieces.firstWhere(

          (piece) => piece.id == id,

    );



    piece.position = newPosition;


  }





  void checkPiecePosition(

      PuzzlePiece piece,

      double tolerance,

      ) {



    final correctX =

        piece.column * tolerance;



    final correctY =

        piece.row * tolerance;



    if (

    (piece.position.dx - correctX).abs()

        < tolerance &&


        (piece.position.dy - correctY).abs()

            < tolerance

    ) {


      piece.placed = true;



      piece.position = Offset(

        correctX,

        correctY,

      );


    }


  }





  bool get isCompleted {



    return pieces.every(

          (piece) => piece.placed,

    );


  }





  int get completedPieces {



    return pieces

        .where(

          (piece) => piece.placed,

    )

        .length;


  }



}