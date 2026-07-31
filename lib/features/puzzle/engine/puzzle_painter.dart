import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzlePainter extends CustomPainter {


  final PuzzlePiece piece;

  final ImageProvider image;

  final ui.Image? cachedImage;


  final double pieceSize;


  final double padding;



  PuzzlePainter({

    required this.piece,

    required this.image,

    this.cachedImage,

    required this.pieceSize,

    this.padding = 0,

  });



  @override
  void paint(

    Canvas canvas,

    Size size,

  ) {


    final path = createPiecePath(size);



    // ظل القطعة

    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(0.25)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          5,

        ),

    );



    // صورة القطعة

    if(cachedImage != null){


      canvas.save();


      canvas.clipPath(path);



      final source = piece.sourceRect;



      // تمديد الصورة حتى تدخل داخل النتوءات

      final destination = Rect.fromLTWH(

        -size.width * 0.15,

        -size.height * 0.15,

        size.width * 1.3,

        size.height * 1.3,

      );



      canvas.drawImageRect(

        cachedImage!,

        source,

        destination,

        Paint()

          ..filterQuality = FilterQuality.high

          ..isAntiAlias = true,

      );


      canvas.restore();


    }



    // إطار خفيف

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1

        ..color = Colors.white.withOpacity(0.35),

    );

  }






  Path createPiecePath(

    Size size,

  ){


    final path = Path();


    final w = size.width;

    final h = size.height;



    final tab =

        w * 0.18;



    final cx = w / 2;

    final cy = h / 2;



    path.moveTo(0,0);



    path.lineTo(

      cx-tab,

      0,

    );


    drawTop(

      path,

      piece.top,

      cx,

      0,

      tab,

    );


    path.lineTo(

      w,

      0,

    );



    path.lineTo(

      w,

      cy-tab,

    );


    drawRight(

      path,

      piece.right,

      w,

      cy,

      tab,

    );


    path.lineTo(

      w,

      h,

    );



    path.lineTo(

      cx+tab,

      h,

    );


    drawBottom(

      path,

      piece.bottom,

      cx,

      h,

      tab,

    );


    path.lineTo(

      0,

      h,

    );



    path.lineTo(

      0,

      cy+tab,

    );


    drawLeft(

      path,

      piece.left,

      0,

      cy,

      tab,

    );


    path.close();


    return path;

  }






  void drawTop(

    Path path,

    EdgeType type,

    double x,

    double y,

    double tab,

  ){


    if(type==EdgeType.tab){

      path.cubicTo(

        x-tab,

        y-tab,

        x+tab,

        y-tab,

        x+tab,

        y,

      );

    }

    else if(type==EdgeType.blank){

      path.cubicTo(

        x-tab,

        y+tab,

        x+tab,

        y+tab,

        x+tab,

        y,

      );

    }

  }





  void drawBottom(

    Path path,

    EdgeType type,

    double x,

    double y,

    double tab,

  ){


    if(type==EdgeType.tab){

      path.cubicTo(

        x+tab,

        y+tab,

        x-tab,

        y+tab,

        x-tab,

        y,

      );

    }

    else if(type==EdgeType.blank){

      path.cubicTo(

        x+tab,

        y-tab,

        x-tab,

        y-tab,

        x-tab,

        y,

      );

    }

  }






  void drawRight(

    Path path,

    EdgeType type,

    double x,

    double y,

    double tab,

  ){


    if(type==EdgeType.tab){

      path.cubicTo(

        x+tab,

        y-tab,

        x+tab,

        y+tab,

        x,

        y+tab,

      );

    }

    else if(type==EdgeType.blank){

      path.cubicTo(

        x-tab,

        y-tab,

        x-tab,

        y+tab,

        x,

        y+tab,

      );

    }

  }







  void drawLeft(

    Path path,

    EdgeType type,

    double x,

    double y,

    double tab,

  ){


    if(type==EdgeType.tab){

      path.cubicTo(

        x-tab,

        y+tab,

        x-tab,

        y-tab,

        x,

        y-tab,

      );

    }

    else if(type==EdgeType.blank){

      path.cubicTo(

        x+tab,

        y+tab,

        x+tab,

        y-tab,

        x,

        y-tab,

      );

    }

  }





  @override
  bool shouldRepaint(

    covariant PuzzlePainter oldDelegate,

  ){

    return oldDelegate.piece != piece ||

        oldDelegate.cachedImage != cachedImage;

  }

}