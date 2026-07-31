import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


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


    final path = createPiecePath(size);


    final w = size.width;

    final h = size.height;


    final tab =

        (w < h ? w : h) * 0.18;



    //=========================================
    // ظل القطعة
    //=========================================

    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(0.25)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          5,

        ),

    );




    //=========================================
    // رسم الصورة
    //=========================================

    if (cachedImage != null) {


      canvas.save();


      canvas.clipPath(path);



      final source = piece.sourceRect;



      final destination = Rect.fromLTWH(

        -tab * 0.15,

        -tab * 0.15,

        size.width + tab * 0.30,

        size.height + tab * 0.30,

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




    //=========================================
    // لمعان بسيط
    //=========================================

    canvas.drawPath(

      path,

      Paint()

        ..shader = LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [

            Colors.white.withOpacity(0.10),

            Colors.transparent,

            Colors.black.withOpacity(0.05),

          ],

        ).createShader(

          Offset.zero & size,

        ),

    );





    //=========================================
    // إطار القطعة
    //=========================================

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1

        ..isAntiAlias = true

        ..color = Colors.white.withOpacity(0.35),

    );



  }





  Path createPiecePath(

    Size size,

  ) {


    final path = Path();



    final w = size.width;

    final h = size.height;



    final tab =

        (w < h ? w : h) * 0.18;



    final centerX = w / 2;

    final centerY = h / 2;




    path.moveTo(

      0,

      0,

    );




    //=========================
    // أعلى
    //=========================

    path.lineTo(

      centerX - tab,

      0,

    );


    drawTop(

      path,

      piece.top,

      centerX,

      0,

      tab,

    );


    path.lineTo(

      w,

      0,

    );




    //=========================
    // يمين
    //=========================

    path.lineTo(

      w,

      centerY - tab,

    );


    drawRight(

      path,

      piece.right,

      w,

      centerY,

      tab,

    );


    path.lineTo(

      w,

      h,

    );




    //=========================
    // أسفل
    //=========================

    path.lineTo(

      centerX + tab,

      h,

    );


    drawBottom(

      path,

      piece.bottom,

      centerX,

      h,

      tab,

    );


    path.lineTo(

      0,

      h,

    );




    //=========================
    // يسار
    //=========================

    path.lineTo(

      0,

      centerY + tab,

    );


    drawLeft(

      path,

      piece.left,

      0,

      centerY,

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

  ) {


    if(type == EdgeType.tab){


      path.cubicTo(

        x - tab,

        y - tab,

        x + tab,

        y - tab,

        x + tab,

        y,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        x - tab,

        y + tab,

        x + tab,

        y + tab,

        x + tab,

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

  ) {


    if(type == EdgeType.tab){


      path.cubicTo(

        x + tab,

        y + tab,

        x - tab,

        y + tab,

        x - tab,

        y,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        x + tab,

        y - tab,

        x - tab,

        y - tab,

        x - tab,

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

  ) {


    if(type == EdgeType.tab){


      path.cubicTo(

        x + tab,

        y - tab,

        x + tab,

        y + tab,

        x,

        y + tab,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        x - tab,

        y - tab,

        x - tab,

        y + tab,

        x,

        y + tab,

      );


    }

  }







  void drawLeft(

    Path path,

    EdgeType type,

    double x,

    double y,

    double tab,

  ) {


    if(type == EdgeType.tab){


      path.cubicTo(

        x - tab,

        y + tab,

        x - tab,

        y - tab,

        x,

        y - tab,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        x + tab,

        y + tab,

        x + tab,

        y - tab,

        x,

        y - tab,

      );


    }

  }






  @override
  bool shouldRepaint(
    covariant PuzzlePainter oldDelegate,
  ) {


    return oldDelegate.piece != piece ||

        oldDelegate.cachedImage != cachedImage ||

        oldDelegate.image != image;

  }

}