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



  // ظل القطعة

  canvas.drawPath(

    path,

    Paint()

      ..color = Colors.black.withOpacity(0.25)

      ..maskFilter = const MaskFilter.blur(

        BlurStyle.normal,

        4,

      ),

  );





  // رسم الصورة داخل القطعة

  if(cachedImage != null){



    canvas.save();



    canvas.clipPath(path);





    final imageWidth =

    cachedImage!.width.toDouble();



    final imageHeight =

    cachedImage!.height.toDouble();






    /*
      تحويل إحداثيات القطعة
      حسب الحجم الحقيقي للصورة

      يعمل مع:
      512
      1024
      2048
      وأي حجم آخر
    */



    final scaleX =

        imageWidth / 1024;



    final scaleY =

        imageHeight / 1024;







    final source = Rect.fromLTWH(



      piece.sourceRect.left * scaleX,



      piece.sourceRect.top * scaleY,



      piece.sourceRect.width * scaleX,



      piece.sourceRect.height * scaleY,



    );







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

        ..filterQuality = FilterQuality.high,



    );






    canvas.restore();



  }






  // إطار القطعة

  canvas.drawPath(

    path,

    Paint()

      ..style = PaintingStyle.stroke

      ..strokeWidth = piece.placed ? 3 : 1.5

      ..color = piece.placed

          ? Colors.greenAccent

          : Colors.white,


  );


}









  Path createPiecePath(Size size){


    final path = Path();



    final w = size.width;

    final h = size.height;

    final tab = w * 0.20;



    path.moveTo(0,0);



    path.lineTo(

      w / 2 - tab,

      0,

    );



    drawTop(

      path,

      piece.top,

      w,

      tab,

    );



    path.lineTo(

      w,

      0,

    );



    path.lineTo(

      w,

      h / 2 - tab,

    );



    drawRight(

      path,

      piece.right,

      h,

      tab,

    );



    path.lineTo(

      w,

      h,

    );



    path.lineTo(

      w / 2 + tab,

      h,

    );



    drawBottom(

      path,

      piece.bottom,

      w,

      h,

      tab,

    );



    path.lineTo(

      0,

      h,

    );



    path.lineTo(

      0,

      h / 2 + tab,

    );



    drawLeft(

      path,

      piece.left,

      h,

      tab,

    );



    path.close();



    return path;

  }









  void drawTop(

      Path path,

      EdgeType type,

      double w,

      double tab,

      ){


    if(type == EdgeType.tab){


      path.cubicTo(

        w / 2 - tab,

        -tab,

        w / 2 + tab,

        -tab,

        w / 2 + tab,

        0,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        w / 2 - tab,

        tab,

        w / 2 + tab,

        tab,

        w / 2 + tab,

        0,

      );


    }


  }









  void drawBottom(

      Path path,

      EdgeType type,

      double w,

      double h,

      double tab,

      ){


    if(type == EdgeType.tab){


      path.cubicTo(

        w / 2 + tab,

        h + tab,

        w / 2 - tab,

        h + tab,

        w / 2 - tab,

        h,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        w / 2 + tab,

        h - tab,

        w / 2 - tab,

        h - tab,

        w / 2 - tab,

        h,

      );


    }


  }









  void drawRight(

      Path path,

      EdgeType type,

      double h,

      double tab,

      ){


    if(type == EdgeType.tab){


      path.cubicTo(

        tab,

        h / 2 - tab,

        tab,

        h / 2 + tab,

        0,

        h / 2 + tab,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        -tab,

        h / 2 - tab,

        -tab,

        h / 2 + tab,

        0,

        h / 2 + tab,

      );


    }


  }









  void drawLeft(

      Path path,

      EdgeType type,

      double h,

      double tab,

      ){


    if(type == EdgeType.tab){


      path.cubicTo(

        -tab,

        h / 2 + tab,

        -tab,

        h / 2 - tab,

        0,

        h / 2 - tab,

      );


    }


    else if(type == EdgeType.blank){


      path.cubicTo(

        tab,

        h / 2 + tab,

        tab,

        h / 2 - tab,

        0,

        h / 2 - tab,

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