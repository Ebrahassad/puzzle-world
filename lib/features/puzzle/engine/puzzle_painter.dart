import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';
import 'puzzle_piece_clipper.dart';


///======================================================
/// رسم صورة قطعة البازل داخل شكلها
///======================================================

class PuzzlePainter extends CustomPainter {


  final PuzzlePiece piece;


  final ui.Image image;



  PuzzlePainter({

    required this.piece,

    required this.image,

  });





  @override
  void paint(

    Canvas canvas,

    Size size,

  ) {


    final path =

        PuzzlePieceClipper(

          piece: piece,

        ).getClip(

          size,

        );




    // حفظ منطقة القطعة

    canvas.save();



    canvas.clipPath(

      path,

    );




    //==================================================
    // حساب مكان الصورة
    //==================================================


    final source =

        Rect.fromLTWH(

          piece.sourceRect.left,

          piece.sourceRect.top,

          piece.sourceRect.width,

          piece.sourceRect.height,

        );



    final destination =

        Rect.fromLTWH(

          0,

          0,

          size.width,

          size.height,

        );





    final paint = Paint()

      ..filterQuality =

          FilterQuality.high;




    canvas.drawImageRect(

      image,

      source,

      destination,

      paint,

    );



    canvas.restore();





    // رسم ظل خفيف حول القطعة

    _drawShadow(

      canvas,

      path,

      size,

    );


  }




  //====================================================
  // ظل القطعة
  //====================================================

  void _drawShadow(

    Canvas canvas,

    Path path,

    Size size,

  ) {


    final shadowPaint = Paint()

      ..color =

          Colors.black.withOpacity(

            0.18,

          )

      ..style =

          PaintingStyle.stroke

      ..strokeWidth =

          1.5;



    canvas.drawPath(

      path,

      shadowPaint,

    );

  }

  //====================================================
  // رسم تأثير عند سحب القطعة
  //====================================================

  void drawActiveEffect(

    Canvas canvas,

    Path path,

  ) {


    final paint = Paint()

      ..style = PaintingStyle.stroke

      ..strokeWidth = 2.0

      ..color = Colors.white.withOpacity(

        0.55,

      );



    canvas.drawPath(

      path,

      paint,

    );

  }





    //====================================================
  // إعادة الرسم
  //====================================================

  @override
  bool shouldRepaint(

    covariant PuzzlePainter oldDelegate,

  ) {


    return

        oldDelegate.piece.position !=

            piece.position

        ||

        oldDelegate.piece.placed !=

            piece.placed

        ||

        oldDelegate.image !=

            image;

  }

}
}