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

    Offset position = Offset.zero,

    bool shadow = false,

  }) {



    canvas.save();





    // نقل القطعة لمكانها

    canvas.translate(

      position.dx,

      position.dy,

    );







    final path = piece.path;









    //==================================================
    // ظل القطعة
    //==================================================

    if(shadow) {



      final shadowPaint = Paint()

        ..color = Colors.black38

        ..maskFilter =

        const MaskFilter.blur(

          BlurStyle.normal,

          6,

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







    final paint = Paint()

      ..filterQuality =

      FilterQuality.high;







    canvas.drawImageRect(

      image,

      piece.sourceRect,

      Rect.fromLTWH(

        -pieceSize.width * 0.12,

        -pieceSize.height * 0.12,

        pieceSize.width * 1.24,

        pieceSize.height * 1.24,

      ),

      paint,

    );







    canvas.restore();









    //==================================================
    // حدود القطعة
    //==================================================

    final border = Paint()

      ..style = PaintingStyle.stroke

      ..strokeWidth = 1.3

      ..color = Colors.black26;







    canvas.drawPath(

      path,

      border,

    );







    canvas.restore();



  }



}