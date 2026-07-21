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

      ){



    final path = createPiecePath(size);




    // ظل 3D للقطعة

    canvas.save();



    canvas.translate(3, 5);



    canvas.drawPath(



      path,



      Paint()



        ..color = Colors.black38



        ..maskFilter =

        const MaskFilter.blur(



          BlurStyle.normal,



          6,



        ),



    );



    canvas.restore();






    // قص الصورة داخل شكل القطعة

    canvas.save();



    canvas.clipPath(path);




    paintImage(



      canvas: canvas,



      rect:

      Offset.zero & size,



      image:image,



      fit:

      BoxFit.cover,



    );



    canvas.restore();







    // إطار القطعة

    canvas.drawPath(



      path,



      Paint()



        ..style = PaintingStyle.stroke



        ..strokeWidth = 2



        ..color = Colors.white,



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




    drawEdge(

      path,

      piece.top,

      Offset(

        w/2,

        0,

      ),

      tab,

      true,

    );



    path.lineTo(w,0);





    // يمين

    path.lineTo(

      w,

      h/2-tab,

    );



    drawEdge(

      path,

      piece.right,

      Offset(

        w,

        h/2,

      ),

      tab,

      false,

    );



    path.lineTo(w,h);







    // أسفل

    path.lineTo(

      w/2+tab,

      h,

    );



    drawEdge(

      path,

      piece.bottom,

      Offset(

        w/2,

        h,

      ),

      tab,

      true,

    );



    path.lineTo(0,h);







    // يسار

    path.lineTo(

      0,

      h/2+tab,

    );



    drawEdge(

      path,

      piece.left,

      Offset(

        0,

        h/2,

      ),

      tab,

      false,

    );




    path.close();



    return path;

  }









  void drawEdge(

      Path path,

      EdgeType type,

      Offset center,

      double tab,

      bool horizontal,

      ){



    if(type == EdgeType.flat){



      if(horizontal){

        path.lineTo(

          center.dx + tab,

          center.dy,

        );

      }

      return;

    }







    if(horizontal){



      if(type == EdgeType.tab){



        path.quadraticBezierTo(



          center.dx,



          center.dy - tab,



          center.dx + tab,



          center.dy,



        );



      }



      else {



        path.quadraticBezierTo(



          center.dx,



          center.dy + tab,



          center.dx + tab,



          center.dy,



        );



      }





    }



    else {



      if(type == EdgeType.tab){



        path.quadraticBezierTo(



          center.dx + tab,



          center.dy,



          center.dx,



          center.dy + tab,



        );



      }



      else {



        path.quadraticBezierTo(



          center.dx - tab,



          center.dy,



          center.dx,



          center.dy + tab,



        );



      }



    }



  }









  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ){



    return true;


  }



}
