import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



//==================================================
// رسام قطعة البازل
//==================================================

class PuzzlePiecePainter {


  static void paint({

    required Canvas canvas,

    required PuzzlePiece piece,

    required ui.Image image,

    required Size pieceSize,

    bool showShadow = false,

  }) {



    canvas.save();




    // نقل القطعة لمكانها الحالي

    canvas.translate(

      piece.position.dx,

      piece.position.dy,

    );






    final path = piece.path;





    //==================================================
    // ظل القطعة
    //==================================================

    if(showShadow || piece.dragging){



      final shadowPaint = Paint()

        ..color = Colors.black45

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          8,

        );




      canvas.drawPath(

        path,

        shadowPaint,

      );


    }







    //==================================================
    // قص الصورة داخل شكل القطعة
    //==================================================


    canvas.save();



    canvas.clipPath(

      path,

    );





    final imagePaint = Paint()

      ..filterQuality = FilterQuality.high;





    canvas.drawImageRect(

      image,

      piece.sourceRect,

      Rect.fromLTWH(

        0,

        0,

        pieceSize.width,

        pieceSize.height,

      ),

      imagePaint,

    );





    canvas.restore();









    //==================================================
    // إطار القطعة
    //==================================================


    final borderPaint = Paint()

      ..style = PaintingStyle.stroke

      ..strokeWidth = 1.5

      ..color = Colors.black26;





    canvas.drawPath(

      path,

      borderPaint,

    );






    //==================================================
    // لمعان بسيط للقطعة المثبتة
    //==================================================


    if(piece.state == PieceState.locked){



      final glow = Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = Colors.white24;




      canvas.drawPath(

        path,

        glow,

      );


    }







    canvas.restore();


  }

}