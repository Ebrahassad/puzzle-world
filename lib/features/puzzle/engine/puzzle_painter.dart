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

    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(.25)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          5,

        ),

    );







    final imageStream = image.resolve(

      const ImageConfiguration(),

    );



    imageStream.addListener(

      ImageStreamListener(

            (info, _) {


          canvas.save();


          canvas.clipPath(path);



          final src = piece.sourceRect;


          final dst = Offset.zero & size;



          canvas.drawImageRect(

            info.image,

            src,

            dst,

            Paint(),

          );



          canvas.restore();





          canvas.drawPath(

            path,

            Paint()

              ..style = PaintingStyle.stroke

              ..strokeWidth = piece.placed ? 3 : 2

              ..color = piece.placed

                  ? Colors.greenAccent

                  : Colors.white,

          );



        },

      ),

    );



  }









  Path createPiecePath(Size size){



    final path = Path();



    final w = size.width;

    final h = size.height;



    final tab = w * .20;





    path.moveTo(0,0);





    // أعلى

    path.lineTo(

      w/2-tab,

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






    // يمين

    path.lineTo(

      w,

      h/2-tab,

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






    // أسفل

    path.lineTo(

      w/2+tab,

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






    // يسار

    path.lineTo(

      0,

      h/2+tab,

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

        w/2-tab,

        -tab,

        w/2+tab,

        -tab,

        w/2+tab,

        0,

      );

    }


    else if(type == EdgeType.blank){

      path.cubicTo(

        w/2-tab,

        tab,

        w/2+tab,

        tab,

        w/2+tab,

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

        w/2+tab,

        h+tab,

        w/2-tab,

        h+tab,

        w/2-tab,

        h,

      );

    }


    else if(type == EdgeType.blank){

      path.cubicTo(

        w/2+tab,

        h-tab,

        w/2-tab,

        h-tab,

        w/2-tab,

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

        h/2-tab,

        tab,

        h/2+tab,

        0,

        h/2+tab,

      );

    }


    else if(type == EdgeType.blank){

      path.cubicTo(

        -tab,

        h/2-tab,

        -tab,

        h/2+tab,

        0,

        h/2+tab,

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

        h/2+tab,

        -tab,

        h/2-tab,

        0,

        h/2-tab,

      );

    }


    else if(type == EdgeType.blank){

      path.cubicTo(

        tab,

        h/2+tab,

        tab,

        h/2-tab,

        0,

        h/2-tab,

      );

    }

  }









  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate

      ){


    return true;


  }



}