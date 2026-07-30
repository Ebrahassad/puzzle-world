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





    //========================================
    // ظل القطعة
    //========================================


    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(0.25)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          4,

        ),

    );





    //========================================
    // رسم صورة القطعة
    //========================================


    if (cachedImage != null) {


      canvas.save();



      canvas.clipPath(path);



      final source = piece.sourceRect;



      final destination = Rect.fromLTWH(

        0,

        0,

        size.width,

        size.height,

      );



      canvas.drawImageRect(

        cachedImage!,

        source,

        destination,

        Paint()

          ..filterQuality =

              FilterQuality.high,

      );



      canvas.restore();


    }





    //========================================
    // إطار خفيف للقطعة
    //========================================


    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 0.8

        ..color = Colors.white.withOpacity(0.35),

    );


  }

  Path createPiecePath(

    Size size,

  ) {


    final path = Path();



    final w = size.width;

    final h = size.height;



    // حجم البروز

    final tab =

        (w < h ? w : h) * 0.18;



    final centerX = w / 2;

    final centerY = h / 2;





    // البداية من الزاوية

    path.moveTo(

      0,

      0,

    );





    //=============================
    // الحافة العلوية
    //=============================


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





    //=============================
    // الحافة اليمنى
    //=============================


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





    //=============================
    // الحافة السفلية
    //=============================


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





    //=============================
    // الحافة اليسرى
    //=============================


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


    if (type == EdgeType.tab) {


      path.cubicTo(

        x - tab,

        y - tab,

        x + tab,

        y - tab,

        x + tab,

        y,

      );


    }

    else if (type == EdgeType.blank) {


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


    if (type == EdgeType.tab) {


      path.cubicTo(

        x + tab,

        y + tab,

        x - tab,

        y + tab,

        x - tab,

        y,

      );


    }

    else if (type == EdgeType.blank) {


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


    if (type == EdgeType.tab) {


      path.cubicTo(

        x + tab,

        y - tab,

        x + tab,

        y + tab,

        x,

        y + tab,

      );


    }

    else if (type == EdgeType.blank) {


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


    if (type == EdgeType.tab) {


      path.cubicTo(

        x - tab,

        y + tab,

        x - tab,

        y - tab,

        x,

        y - tab,

      );


    }

    else if (type == EdgeType.blank) {


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

        oldDelegate.cachedImage != cachedImage;


  }


}