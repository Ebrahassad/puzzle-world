import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleGenerator {


  PuzzleGenerator._();



  //======================================================
  // إنشاء قطع البازل
  //======================================================

  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required double imageWidth,

    required double imageHeight,

    Random? random,

  }) {


    final rng =
        random ?? Random();



    final pieces =
        <PuzzlePiece>[];



    final pieceWidth =
        imageWidth / columns;



    final pieceHeight =
        imageHeight / rows;



    final tabSize =
        min(
          pieceWidth,
          pieceHeight,
        ) * 0.18;



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



    for(
      int row = 0;
      row < rows;
      row++
    ) {


      for(
        int column = 0;
        column < columns;
        column++
      ) {



        final sourceRect =
            Rect.fromLTWH(

              column * pieceWidth,

              row * pieceHeight,

              pieceWidth,

              pieceHeight,

            );



        final targetPosition =
            Offset(

              column * pieceWidth,

              row * pieceHeight,

            );



        final piece =
            PuzzlePiece(

              id:
                  "piece_$index",



              row:
                  row,



              column:
                  column,



              correctIndex:
                  index,



              sourceRect:
                  sourceRect,



              top:
                  row == 0

                  ? const PuzzleEdge(
                      type: EdgeType.flat,
                      side: EdgeSide.top,
                    )

                  : PuzzleEdge(
                      type:
                          _reverse(
                            verticalEdges[row - 1][column],
                          ),

                      side:
                          EdgeSide.top,
                    ),



              right:
                  column == columns - 1

                  ? const PuzzleEdge(
                      type: EdgeType.flat,
                      side: EdgeSide.right,
                    )

                  : PuzzleEdge(
                      type:
                          horizontalEdges[row][column],

                      side:
                          EdgeSide.right,
                    ),



              bottom:
                  row == rows - 1

                  ? const PuzzleEdge(
                      type: EdgeType.flat,
                      side: EdgeSide.bottom,
                    )

                  : PuzzleEdge(
                      type:
                          verticalEdges[row][column],

                      side:
                          EdgeSide.bottom,
                    ),



              left:
                  column == 0

                  ? const PuzzleEdge(
                      type: EdgeType.flat,
                      side: EdgeSide.left,
                    )

                  : PuzzleEdge(
                      type:
                          _reverse(
                            horizontalEdges[row][column - 1],
                          ),

                      side:
                          EdgeSide.left,
                    ),



              targetPosition:
                  targetPosition,



              size:
                  Size(
                    pieceWidth,
                    pieceHeight,
                  ),



              tabSize:
                  tabSize,



              position:
                  Offset.zero,

            );



        pieces.add(piece);



        index++;

      }

    }

    //======================================================
    // توزيع القطع عشوائياً
    //======================================================

    pieces.shuffle(rng);


    // وضع القطع في أماكن عشوائية
    for (int i = 0; i < pieces.length; i++) {

      pieces[i].position =
          Offset(

            rng.nextDouble() *
                (imageWidth - pieceWidth),

            rng.nextDouble() *
                (imageHeight - pieceHeight),

          );


      pieces[i].zIndex = i;

    }


    return pieces;

  }



  //======================================================
  // إنشاء الحواف الأفقية
  //======================================================

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




  //======================================================
  // إنشاء الحواف الرأسية
  //======================================================

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




  //======================================================
  // إنشاء حافة عشوائية
  //======================================================

  static EdgeType _randomEdge(

    Random random,

  ) {


    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;

  }





  //======================================================
  // عكس الحافة المقابلة
  //======================================================

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