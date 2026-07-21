import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleGenerator {



  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required double imageWidth,

    required double imageHeight,

  }) {



    final random = Random();



    final pieces = <PuzzlePiece>[];



    final pieceWidth =
        imageWidth / columns;


    final pieceHeight =
        imageHeight / rows;



    int id = 0;



    for (int row = 0; row < rows; row++) {


      for (int column = 0;
      column < columns;
      column++) {



        final piece = PuzzlePiece(


          id: id,


          correctPosition: id,


          row: row,


          column: column,


          sourceRect: Rect.fromLTWH(

            column * pieceWidth,

            row * pieceHeight,

            pieceWidth,

            pieceHeight,

          ),



          top: row == 0

              ? EdgeType.flat

              : _randomEdge(random),



          bottom: row == rows - 1

              ? EdgeType.flat

              : _randomEdge(random),



          left: column == 0

              ? EdgeType.flat

              : _randomEdge(random),



          right: column == columns - 1

              ? EdgeType.flat

              : _randomEdge(random),



          position: Offset(

            column * pieceWidth,

            row * pieceHeight,

          ),



        );



        pieces.add(piece);



        id++;


      }


    }



    pieces.shuffle(random);



    return pieces;


  }





  static EdgeType _randomEdge(Random random) {


    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;


  }


}