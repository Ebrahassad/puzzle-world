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




    // ظل ثلاثي الأبعاد

    canvas.save();



    canvas.translate(4, 6);



    canvas.drawPath(



      path,



      Paint()



        ..color = Colors.black38



        ..maskFilter =

        const MaskFilter.blur(

          BlurStyle.normal,

          8,

        ),



    );



    canvas.restore();






    // قص القطعة

    canvas.save();



    canvas.clipPath(path);





    final imageConfiguration =

    ImageConfiguration.empty;



    final stream =

    image.resolve(

      imageConfiguration,

    );




    stream.addListener(

      ImageStreamListener(

            (info, _) {



          final imageSize =

          Size(

            info.image.width.toDouble(),

            info.image.height.toDouble(),

          );




          final src =

          piece.sourceRect;




          final dst =

          Offset.zero & size;




          canvas.drawImageRect(



            info.image,



            src,



            dst,



            Paint(),

          );



        },

      ),

    );




    canvas.restore();







    // حدود القطعة

    canvas.drawPath(



      path,



      Paint()



        ..style = PaintingStyle.stroke



        ..strokeWidth = 2



        ..color = Colors.white.withOpacity(.9),



    );



  }









  Path createPiecePath(Size size) {



    final path = Path();



    final w = size.width;


    final h = size.height;



    final tab = w * .22;





    path.moveTo(0,0);






    // الأعلى

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






    // اليمين

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






    // الأسفل

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






    // اليسار

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



      path.quadraticBezierTo(

        w/2,

        -tab,

        w/2 + tab,

        0,

      );



    }


    else if(type == EdgeType.blank){



      path.quadraticBezierTo(

        w/2,

        tab,

        w/2 + tab,

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



      path.quadraticBezierTo(

        w/2,

        h + tab,

        w/2 - tab,

        h,

      );



    }



    else if(type == EdgeType.blank){



      path.quadraticBezierTo(

        w/2,

        h - tab,

        w/2 - tab,

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



      path.quadraticBezierTo(

        tab + 0,

        h/2,

        0,

        h/2 + tab,

      );



    }


    else if(type == EdgeType.blank){



      path.quadraticBezierTo(

        -tab,

        h/2,

        0,

        h/2 + tab,

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



      path.quadraticBezierTo(

        -tab,

        h/2,

        0,

        h/2 - tab,

      );



    }



    else if(type == EdgeType.blank){



      path.quadraticBezierTo(

        tab,

        h/2,

        0,

        h/2 - tab,

      );



    }



  }









  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ){



    return true;


  }


}
