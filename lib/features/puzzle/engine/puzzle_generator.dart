import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzleGenerator {

  PuzzleGenerator._();



  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required double imageWidth,

    required double imageHeight,

    Random? random,

  }) {


    final rng = random ?? Random();


    final pieces = <PuzzlePiece>[];



    final pieceWidth =
        imageWidth / columns;


    final pieceHeight =
        imageHeight / rows;



    // إنشاء الحواف المشتركة
    final horizontalEdges =
        _createHorizontalEdges(

          rows,

          columns,

          rng,

        );


    final verticalEdges =
        _createVerticalEdges(

          rows,

          columns,

          rng,

        );



    int index = 0;



    for (int row = 0; row < rows; row++) {


      for (int column = 0;
          column < columns;
          column++) {



        final sourceRect =
            Rect.fromLTWH(

              column * pieceWidth,

              row * pieceHeight,

              pieceWidth,

              pieceHeight,

            );



        final piece = PuzzlePiece(

          id: "piece_$index",


          row: row,


          column: column,


          correctPosition: index,


          sourceRect: sourceRect,



          // الحواف الخارجية تكون مستقيمة
          top: row == 0

              ? EdgeType.flat

              : _reverse(

                  verticalEdges[row - 1][column],

                ),



          bottom: row == rows - 1

              ? EdgeType.flat

              : verticalEdges[row][column],



          left: column == 0

              ? EdgeType.flat

              : _reverse(

                  horizontalEdges[row][column - 1],

                ),



          right: column == columns - 1

              ? EdgeType.flat

              : horizontalEdges[row][column],



          position: Offset.zero,

        );



        pieces.add(piece);



        index++;


      }

    }



    // خلط أماكن ظهور القطع فقط
    pieces.shuffle(rng);



    return pieces;

  }
  static List<List<EdgeType>> _createHorizontalEdges(

    int rows,

    int columns,

    Random random,

  ) {


    return List.generate(

      rows,

      (_) => List.generate(

        columns - 1,

        (_) => _randomEdge(random),

      ),

    );

  }




  static List<List<EdgeType>> _createVerticalEdges(

    int rows,

    int columns,

    Random random,

  ) {


    return List.generate(

      rows - 1,

      (_) => List.generate(

        columns,

        (_) => _randomEdge(random),

      ),

    );

  }





  static EdgeType _randomEdge(

    Random random,

  ) {


    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;

  }





  static EdgeType _reverse(

    EdgeType edge,

  ) {


    switch(edge) {


      case EdgeType.tab:

        return EdgeType.blank;



      case EdgeType.blank:

        return EdgeType.tab;



      case EdgeType.flat:

        return EdgeType.flat;

    }

  }

}