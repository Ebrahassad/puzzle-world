import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



//==================================================
// رسام قطعة البازل
//==================================================

class PuzzlePainter extends CustomPainter {



  final PuzzlePiece piece;


  final ImageProvider image;


  final ui.Image? cachedImage;





  PuzzlePainter({



    required this.piece,



    required this.image,



    this.cachedImage,



  });








  @override

  void paint(

      Canvas canvas,

      Size size,

      ) {



    final img = cachedImage;



    if(img == null){

      return;

    }




    canvas.save();






    final path = piece.path;






    //==================================================
    // ظل القطعة أثناء السحب
    //==================================================


    if(piece.dragging){



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



      img,



      piece.sourceRect,



      Rect.fromLTWH(

        0,

        0,

        size.width,

        size.height,

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
    // لمعان القطعة المثبتة
    //==================================================


    if(piece.state == PieceState.locked){



      final glowPaint = Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = Colors.white24;




      canvas.drawPath(

        path,

        glowPaint,

      );


    }






    canvas.restore();



  }









  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ){



    return oldDelegate.piece != piece ||

        oldDelegate.cachedImage != cachedImage;


  }



}