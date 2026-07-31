import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';





//==================================================
// مولد البازل
//==================================================

class PuzzleGenerator {



  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required Size imageSize,

    required Size pieceSize,

    Random? random,

  }) {



    final rng = random ?? Random();



    final pieces = <PuzzlePiece>[];



    final pieceWidth =

        imageSize.width / columns;



    final pieceHeight =

        imageSize.height / rows;







    // الحواف المشتركة

    final horizontalEdges =

    _horizontalEdges(

      rows,

      columns,

      rng,

    );





    final verticalEdges =

    _verticalEdges(

      rows,

      columns,

      rng,

    );







    int index = 0;







    for(int row = 0;

    row < rows;

    row++) {



      for(int column = 0;

      column < columns;

      column++) {







        final source = Rect.fromLTWH(

          column * pieceWidth,

          row * pieceHeight,

          pieceWidth,

          pieceHeight,

        );









        final piece = PuzzlePiece(



          id:

          "piece_$index",




          row:

          row,



          column:

          column,



          sourceRect:

          source,





          top:

          row == 0

              ? EdgeType.flat

              :

          _reverse(

            verticalEdges[row - 1][column],

          ),






          right:

          column == columns - 1

              ? EdgeType.flat

              :

          horizontalEdges[row][column],






          bottom:

          row == rows - 1

              ? EdgeType.flat

              :

          verticalEdges[row][column],






          left:

          column == 0

              ? EdgeType.flat

              :

          _reverse(

            horizontalEdges[row][column - 1],

          ),



        );









        // إنشاء شكل القطعة

        piece.createShape(

          pieceSize,

        );





        pieces.add(piece);



        index++;


      }


    }







    return pieces;


  }









  //==================================================
  // حواف أفقية بين القطع
  //==================================================

  static List<List<EdgeType>> _horizontalEdges(

      int rows,

      int columns,

      Random random,

      ) {



    return List.generate(

      rows,

          (_) => List.generate(

        columns - 1,

            (_) => _randomEdge(

          random,

        ),

      ),

    );

  }









  //==================================================
  // حواف عمودية بين القطع
  //==================================================

  static List<List<EdgeType>> _verticalEdges(

      int rows,

      int columns,

      Random random,

      ) {



    return List.generate(

      rows - 1,

          (_) => List.generate(

        columns,

            (_) => _randomEdge(

          random,

        ),

      ),

    );

  }









  //==================================================
  // اختيار نتوء أو فراغ
  //==================================================

  static EdgeType _randomEdge(

      Random random,

      ) {



    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;


  }









  //==================================================
  // عكس الحافة المقابلة
  //==================================================

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