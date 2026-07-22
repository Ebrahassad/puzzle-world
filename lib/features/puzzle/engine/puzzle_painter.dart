import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzlePainter extends CustomPainter {



  final PuzzlePiece piece;


  final ImageProvider image;



  PuzzlePainter({

    required this.piece,

    required this.image,

  });







  @override
  void paint(

      Canvas canvas,

      Size size,

      ) {



    final path = createPiecePath(size);





    // =========================
    // ظل ثلاثي الأبعاد
    // =========================


    canvas.save();



    canvas.translate(3, 5);



    canvas.drawPath(



      path,



      Paint()



        ..color = Colors.black.withOpacity(.35)



        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          6,

        ),



    );



    canvas.restore();







    // =========================
    // رسم الصورة داخل القطعة
    // =========================


    final paint = Paint();



    final rect = Offset.zero & size;



    final imageStream =

    image.resolve(

      ImageConfiguration.empty,

    );



    imageStream.addListener(



      ImageStreamListener(

            (info, synchronousCall){



          canvas.save();



          canvas.clipPath(path);





          canvas.drawImageRect(



            info.image,



            piece.sourceRect,



            rect,



            paint,



          );





          canvas.restore();




          // حدود القطعة

          canvas.drawPath(



            path,



            Paint()



              ..style = PaintingStyle.stroke



              ..strokeWidth =

              piece.placed ? 3 : 2



              ..color = piece.placed

                  ? Colors.greenAccent

                  : Colors.white.withOpacity(.9),



          );



        },

      ),

    );



  }









  Path createPiecePath(Size size){



    final path = Path();



    final w = size.width;


    final h = size.height;



    final tab = w * .22;





    path.moveTo(0,0);





    // أعلى

    path.lineTo(

      w/2-tab,

      0,

    );



    _top(

      path,

      piece.top,

      w,

      tab,

    );



    path.lineTo(

      w,

      0,

    );





    // يمين

    path.lineTo(

      w,

      h/2-tab,

    );



    _right(

      path,

      piece.right,

      h,

      tab,

    );



    path.lineTo(

      w,

      h,

    );





    // أسفل

    path.lineTo(

      w/2+tab,

      h,

    );



    _bottom(

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





    // يسار

    path.lineTo(

      0,

      h/2+tab,

    );



    _left(

      path,

      piece.left,

      h,

      tab,

    );



    path.close();



    return path;



  }









  void _top(

      Path path,

      EdgeType type,

      double w,

      double tab,

      ){



    if(type == EdgeType.tab){



      path.quadraticBezierTo(

        w/2,

        -tab,

        w/2+tab,

        0,

      );



    }



    if(type == EdgeType.blank){



      path.quadraticBezierTo(

        w/2,

        tab,

        w/2+tab,

        0,

      );



    }



  }









  void _bottom(

      Path path,

      EdgeType type,

      double w,

      double h,

      double tab,

      ){



    if(type == EdgeType.tab){



      path.quadraticBezierTo(

        w/2,

        h+tab,

        w/2-tab,

        h,

      );



    }



    if(type == EdgeType.blank){



      path.quadraticBezierTo(

        w/2,

        h-tab,

        w/2-tab,

        h,

      );



    }



  }









  void _right(

      Path path,

      EdgeType type,

      double h,

      double tab,

      ){



    if(type == EdgeType.tab){



      path.quadraticBezierTo(

        h/2,

        h/2,

        0,

        h/2+tab,

      );



    }



    if(type == EdgeType.blank){



      path.quadraticBezierTo(

        -tab,

        h/2,

        0,

        h/2+tab,

      );



    }



  }









  void _left(

      Path path,

      EdgeType type,

      double h,

      double tab,

      ){



    if(type == EdgeType.tab){



      path.quadraticBezierTo(

        -tab,

        h/2,

        0,

        h/2-tab,

      );



    }



    if(type == EdgeType.blank){



      path.quadraticBezierTo(

        tab,

        h/2,

        0,

        h/2-tab,

      );



    }



  }









  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ){



    return oldDelegate.piece != piece ||

        oldDelegate.image != image;



  }



}