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





    /*
      إنشاء أماكن بداية احترافية
      بدون تداخل بين القطع
    */

    final startPositions =
    <Offset>[];



    final spacing =
        screenPieceSize + 6;



    for(int y = 0; y < rows; y++){

      for(int x = 0; x < columns; x++){


        startPositions.add(

          Offset(

            x * spacing,

            y * spacing,

          ),

        );


      }

    }



    startPositions.shuffle(random);





    int index = 0;





    for(int row = 0; row < rows; row++){



      for(int column = 0; column < columns; column++){





        final sourceRect = Rect.fromLTWH(



          column * pieceWidth,



          row * pieceHeight,



          pieceWidth,



          pieceHeight,



        );







        final top =
        row == 0

            ? EdgeType.flat

            : _reverseEdge(

          verticalEdges[row - 1][column],

        );







        final bottom =
        row == rows - 1

            ? EdgeType.flat

            : verticalEdges[row][column];







        final left =
        column == 0

            ? EdgeType.flat

            : _reverseEdge(

          horizontalEdges[row][column - 1],

        );







        final right =
        column == columns - 1

            ? EdgeType.flat

            : horizontalEdges[row][column];









        Offset startPosition =
        startPositions[index];





        // حماية من خروج القطع خارج اللوحة

        startPosition = Offset(

          startPosition.dx.clamp(

            0,

            boardSize - screenPieceSize,

          ),


          startPosition.dy.clamp(

            0,

            boardSize - screenPieceSize,

          ),


        );







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





            position:

            startPosition,



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