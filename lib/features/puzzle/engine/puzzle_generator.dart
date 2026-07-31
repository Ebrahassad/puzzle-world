import 'dart:math';

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



//==================================================
// مولد قطع البازل
//==================================================

class PuzzleGenerator {


  static List<PuzzlePiece> generate({

    required int rows,

    required int columns,

    required Size imageSize,

    required Size pieceSize,

    required Size traySize,

    Random? random,

  }) {



    final rng = random ?? Random();


    final pieces = <PuzzlePiece>[];



    final imagePieceWidth =
        imageSize.width / columns;


    final imagePieceHeight =
        imageSize.height / rows;





    // الحواف المشتركة

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



    for(int row = 0; row < rows; row++){


      for(int column = 0; column < columns; column++){



        final sourceRect = Rect.fromLTWH(

          column * imagePieceWidth,

          row * imagePieceHeight,

          imagePieceWidth,

          imagePieceHeight,

        );





        final piece = PuzzlePiece(


          id: "piece_$index",



          row: row,



          column: column,



          sourceRect: sourceRect,



          top:

          row == 0

              ? EdgeType.flat

              : _reverse(

              verticalEdges[row-1][column]

          ),




          right:

          column == columns-1

              ? EdgeType.flat

              : horizontalEdges[row][column],




          bottom:

          row == rows-1

              ? EdgeType.flat

              : verticalEdges[row][column],




          left:

          column == 0

              ? EdgeType.flat

              : _reverse(

              horizontalEdges[row][column-1]

          ),




          // البداية داخل الشريط

          position:

          _trayPosition(

            index,

            traySize,

          ),

        );







        // إنشاء الشكل

        piece.createShape(

          pieceSize,

        );






        // تحديد مكانها الصحيح

        piece.setCorrectPosition(

          pieceSize.width,

        );





        pieces.add(piece);



        index++;


      }

    }




    return pieces;


  }







//==================================================
// مكان القطعة في الشريط العلوي
//==================================================

static Offset _trayPosition(

    int index,

    Size traySize,

    ){



  const double itemSize = 70;

  const double space = 8;



  final columns =

      max(

        1,

        (traySize.width /

            (itemSize+space))

            .floor(),

      );




  final x =

      (index % columns)

          *

      (itemSize+space);





  final y =

      (index ~/ columns)

          *

      (itemSize+space);





  return Offset(

    x,

    y,

  );


}









//==================================================
// إنشاء الحواف الأفقية
//==================================================

static List<List<EdgeType>>

_createHorizontalEdges(

    int rows,

    int columns,

    Random random,

    ){



  return List.generate(

    rows,

        (_) => List.generate(

      columns-1,

          (_) => _randomEdge(random),

    ),

  );


}









//==================================================
// إنشاء الحواف العمودية
//==================================================

static List<List<EdgeType>>

_createVerticalEdges(

    int rows,

    int columns,

    Random random,

    ){



  return List.generate(

    rows-1,

        (_) => List.generate(

      columns,

          (_) => _randomEdge(random),

    ),

  );


}









//==================================================
// اختيار نوع الحافة
//==================================================

static EdgeType _randomEdge(

    Random random,

    ){



  return random.nextBool()

      ? EdgeType.tab

      : EdgeType.blank;


}









//==================================================
// عكس الحافة المقابلة
//==================================================

static EdgeType _reverse(

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