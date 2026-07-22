import 'dart:ui';

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';



class PuzzleImageSplitService {


  static List<PuzzlePiece> splitImage({

    required String imagePath,

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

            imagePath: imagePath,

            position: Offset.zero,

          ),

        );





        index++;


      }


    }





    return pieces;


  }








  static Rect getPieceRect({

    required int row,

    required int column,

    required int gridSize,

    required double imageSize,

  }) {



    final size =

    imageSize / gridSize;





    return Rect.fromLTWH(

      column * size,

      row * size,

      size,

      size,

    );


  }








  static double getPieceSize({

    required double imageSize,

    required int gridSize,

  }) {



    return imageSize / gridSize;


  }








  static Widget buildPieceImage({

    required PuzzlePiece piece,

    required double size,

  }) {



    return ClipRect(



      child:

      SizedBox(

        width:size,

        height:size,



        child:

        Image.asset(

          piece.imagePath,

          fit:BoxFit.none,

          alignment:Alignment(

            -1 +

                (piece.column /

                    (piece.gridSize - 1)) *

                    2,

            -1 +

                (piece.row /

                    (piece.gridSize - 1)) *

                    2,

          ),

        ),

      ),



    );


  }








  static List<PuzzlePiece> shufflePieces(

      List<PuzzlePiece> pieces,

      ) {



    pieces.shuffle();


    return pieces;


  }


}