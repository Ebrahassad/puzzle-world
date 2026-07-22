import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';



class PuzzleBoardService {


  static Offset calculatePosition({

    required int index,

    required int gridSize,

    required double pieceSize,

  }) {



    final row = index ~/ gridSize;

    final column = index % gridSize;





    return Offset(

      column * pieceSize,

      row * pieceSize,

    );


  }








  static int getTargetIndex({

    required Offset position,

    required double pieceSize,

    required int gridSize,

  }) {



    final column =

    (position.dx / pieceSize)

        .floor();



    final row =

    (position.dy / pieceSize)

        .floor();





    return row * gridSize + column;


  }








  static bool isInsideBoard({

    required Offset position,

    required double boardSize,

  }) {



    return position.dx >= 0 &&

        position.dy >= 0 &&

        position.dx <= boardSize &&

        position.dy <= boardSize;


  }








  static bool canPlacePiece({

    required PuzzlePiece piece,

    required double pieceSize,

    required Offset position,

  }) {



    final target =

    getTargetIndex(

      position: position,

      pieceSize: pieceSize,

      gridSize: piece.gridSize,

    );





    return target == piece.correctPosition;


  }








  static void placePiece(

      PuzzlePiece piece,

      Offset position,

      ) {



    piece.position = position;

    piece.placed = true;


  }








  static int countPlaced(

      List<PuzzlePiece> pieces,

      ) {



    return pieces.where(

          (piece) => piece.placed,

    ).length;


  }








  static double progress(

      List<PuzzlePiece> pieces,

      ) {



    if(pieces.isEmpty){

      return 0;

    }





    return countPlaced(

      pieces,

    ) /

        pieces.length;


  }


}