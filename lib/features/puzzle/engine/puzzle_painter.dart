import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';
import 'puzzle_piece_clipper.dart';





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







    canvas.save();





    canvas.clipPath(

      path,

    );







    final source = Rect.fromLTWH(

      piece.sourceRect.left,

      piece.sourceRect.top,

      piece.sourceRect.width,

      piece.sourceRect.height,

    );







    final destination = Rect.fromLTWH(

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






    drawBorder(

      canvas,

      path,

    );



  }


  //==================================================
  // رسم حدود وظل القطعة
  //==================================================

  void drawBorder(

    Canvas canvas,

    Path path,

  ) {



    final paint = Paint()

      ..style = PaintingStyle.stroke


      ..strokeWidth = 1.5


      ..color = Colors.black.withOpacity(

        0.25,

      );





    canvas.drawPath(

      path,

      paint,

    );



  }







  //==================================================
  // إعادة الرسم
  //==================================================

  @override

  bool shouldRepaint(

    covariant PuzzlePainter oldDelegate,

  ) {



    return

        oldDelegate.image != image

        ||

        oldDelegate.piece.position !=

            piece.position

        ||

        oldDelegate.piece.placed !=

            piece.placed;



  }



}