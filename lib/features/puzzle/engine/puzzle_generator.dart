import 'dart:math';
import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleGenerator {


  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required double imageWidth,

    required double imageHeight,

    required double boardSize,

  }) {



    final List<PuzzlePiece> pieces = [];



    final double pieceWidth =
        imageWidth / columns;


    final double pieceHeight =
        imageHeight / rows;



    final double screenPieceSize =
        boardSize / columns;




    final random = Random();





    final horizontalEdges =
    List.generate(

      rows,

          (_) => List.generate(

        columns - 1,

            (_) => _randomEdge(random),

      ),

    );





    final verticalEdges =
    List.generate(

      rows - 1,

          (_) => List.generate(

        columns,

            (_) => _randomEdge(random),

      ),

    );







    int index = 0;





    for(int row = 0; row < rows; row++){



      for(int column = 0; column < columns; column++){





        // قص الصورة حسب الحجم الحقيقي

        final sourceRect = Rect.fromLTWH(



          column * pieceWidth,



          row * pieceHeight,



          pieceWidth,



          pieceHeight,



        );







        final top = row == 0

            ? EdgeType.flat

            : _reverseEdge(

          verticalEdges[row - 1][column],

        );







        final bottom = row == rows - 1

            ? EdgeType.flat

            : verticalEdges[row][column];







        final left = column == 0

            ? EdgeType.flat

            : _reverseEdge(

          horizontalEdges[row][column - 1],

        );







        final right = column == columns - 1

            ? EdgeType.flat

            : horizontalEdges[row][column];








        pieces.add(



          PuzzlePiece(



            id:

            "piece_$index",



            row:

            row,



            column:

            column,



            correctPosition:

            index,



            sourceRect:

            sourceRect,



            top:

            top,



            bottom:

            bottom,



            left:

            left,



            right:

            right,







            // مكان البداية داخل قسم القطع

            position: Offset(



              random.nextDouble() *

                  (boardSize - screenPieceSize),





              random.nextDouble() *

                  (boardSize - screenPieceSize),



            ),



          ),



        );





        index++;



      }



    }





    pieces.shuffle(random);



    return pieces;



  }








  static EdgeType _randomEdge(

      Random random,

      ){



    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;



  }








  static EdgeType _reverseEdge(

      EdgeType edge,

      ){



    switch(edge){



      case EdgeType.tab:

        return EdgeType.blank;



      case EdgeType.blank:

        return EdgeType.tab;



      default:

        return EdgeType.flat;



    }



  }



}