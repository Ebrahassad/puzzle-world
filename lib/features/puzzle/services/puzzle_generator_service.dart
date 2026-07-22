import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';



class PuzzleGeneratorService {


  static List<PuzzlePiece> generatePieces({

    required int gridSize,

    required double imageSize,

  }) {



    final pieces = <PuzzlePiece>[];



    final pieceSize =

    imageSize / gridSize;





    int index = 0;





    for(int row = 0; row < gridSize; row++){


      for(int column = 0; column < gridSize; column++){



        pieces.add(

          PuzzlePiece(

            id: "piece_$index",

            row: row,

            column: column,

            correctPosition: index,

            sourceRect: Rect.fromLTWH(

              column * pieceSize,

              row * pieceSize,

              pieceSize,

              pieceSize,

            ),

            top: EdgeType.flat,

            bottom: EdgeType.flat,

            left: EdgeType.flat,

            right: EdgeType.flat,

            position: Offset(

              Random().nextDouble() *

                  imageSize,

              Random().nextDouble() *

                  imageSize,

            ),

          ),

        );



        index++;


      }


    }





    pieces.shuffle();



    return pieces;


  }








  static List<PuzzlePiece> regenerate({

    required List<PuzzlePiece> pieces,

  }) {



    final random = Random();





    for(final piece in pieces){



      piece.position = Offset(

        random.nextDouble() * 300,

        random.nextDouble() * 300,

      );



      piece.placed = false;


    }





    return pieces;


  }








  static int totalPieces(

      int gridSize,

      ) {



    return gridSize * gridSize;


  }








  static double calculatePieceSize({

    required double boardSize,

    required int gridSize,

  }) {



    return boardSize / gridSize;


  }


}