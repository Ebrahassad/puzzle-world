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

        ..color = Colors.black.withOpacity(0.35)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          5,

        ),

    );





    //========================================
    // رسم الصورة داخل القطعة
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
    // حدود القطعة
    //========================================


    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1.5

        ..color = Colors.white.withOpacity(0.7),

    );


  }





  Path createPiecePath(

    Size size,

  ) {


    final path = Path();



    final w = size.width;

    final h = size.height;



    final tab =

        (w < h ? w : h) * 0.22;



    final left = tab;

    final right = w - tab;

    final top = tab;

    final bottom = h - tab;



    final centerX = w / 2;

    final centerY = h / 2;



    path.moveTo(

      left,

      top,

    );


    path.lineTo(

      centerX - tab,

      top,

    );



    drawTop(

      path,

      piece.top,

      centerX,

      top,

      tab,

    );


    path.lineTo(

      right,

      top,

    );



    path.lineTo(

      right,

      centerY - tab,

    );



    drawRight(

      path,

      piece.right,

      right,

      centerY,

      tab,

    );



    path.lineTo(

      right,

      bottom,

    );



    path.lineTo(

      centerX + tab,

      bottom,

    );


    drawBottom(

      path,

      piece.bottom,

      centerX,

      bottom,

      tab,

    );


    path.lineTo(

      left,

      bottom,

    );



    path.lineTo(

      left,

      centerY + tab,

    );


    drawLeft(

      path,

      piece.left,

      left,

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