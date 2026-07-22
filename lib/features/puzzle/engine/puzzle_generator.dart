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



    final pieceWidth = imageWidth / columns;


    final pieceHeight = imageHeight / rows;





    final horizontalEdges = <String, EdgeType>{};


    final verticalEdges = <String, EdgeType>{};





    int id = 0;







    for(int row = 0; row < rows; row++){



      for(int column = 0; column < columns; column++){





        final top = row == 0

            ? EdgeType.flat

            :

        verticalEdges["${row-1}_$column"]

            ??

        EdgeType.flat;







        final left = column == 0

            ? EdgeType.flat

            :

        horizontalEdges["${row}_${column-1}"]

            ??

        EdgeType.flat;







        final right = column == columns - 1

            ? EdgeType.flat

            :

        _createRandomEdge(random);







        final bottom = row == rows - 1

            ? EdgeType.flat

            :

        _createRandomEdge(random);









        if(column < columns - 1){



          horizontalEdges["${row}_$column"] =

              _oppositeEdge(right);



        }








        if(row < rows - 1){



          verticalEdges["$row_$column"] =

              _oppositeEdge(bottom);



        }









        pieces.add(



          PuzzlePiece(



            id: id.toString(),



            correctPosition:id,



            row:row,



            column:column,



            sourceRect:



            Rect.fromLTWH(



              column * pieceWidth,



              row * pieceHeight,



              pieceWidth,



              pieceHeight,



            ),





            top:top,



            bottom:bottom,



            left:left,



            right:right,





            position:



            Offset(



              column * pieceWidth,



              row * pieceHeight,



            ),



          ),



        );







        id++;



      }



    }









    pieces.shuffle(random);



    return pieces;



  }









  static EdgeType _createRandomEdge(

      Random random,

      ){



    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;



  }









  static EdgeType _oppositeEdge(

      EdgeType edge,

      ){



    switch(edge){



      case EdgeType.tab:

        return EdgeType.blank;



      case EdgeType.blank:

        return EdgeType.tab;



      case EdgeType.flat:

        return EdgeType.flat;



    }



  }



}