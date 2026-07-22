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



    final List<PuzzlePiece> pieces = [];



    final double pieceWidth =

        imageWidth / columns;



    final double pieceHeight =

        imageHeight / rows;



    int index = 0;



    final random = Random();





    for (int row = 0; row < rows; row++) {


      for (int column = 0; column < columns; column++) {



        final sourceRect = Rect.fromLTWH(


          column * pieceWidth,


          row * pieceHeight,


          pieceWidth,


          pieceHeight,


        );





        pieces.add(


          PuzzlePiece(



            id: "piece_$index",



            row: row,



            column: column,



            correctPosition: index,



            sourceRect: sourceRect,



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



              random.nextDouble()

                  * (imageWidth - pieceWidth),



              random.nextDouble()

                  * (imageHeight - pieceHeight),



            ),



          ),


        );



        index++;


      }

    }





    pieces.shuffle(random);



    return pieces;



  }








  static EdgeType _randomEdge(Random random){



    final value = random.nextInt(3);



    switch(value){



      case 1:

        return EdgeType.tab;



      case 2:

        return EdgeType.blank;



      default:

        return EdgeType.flat;



    }


  }


}