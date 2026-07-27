import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';


class PuzzlePieceWidget extends StatefulWidget {


  final PuzzlePiece piece;

  final ImageProvider image;

  final double size;



  const PuzzlePieceWidget({

    super.key,

    required this.piece,

    required this.image,

    required this.size,

  });



  @override
  State<PuzzlePieceWidget> createState() =>
      _PuzzlePieceWidgetState();


}







class _PuzzlePieceWidgetState
    extends State<PuzzlePieceWidget>{



  ui.Image? image;



  @override
  void didChangeDependencies(){


    super.didChangeDependencies();


    loadImage();


  }






  void loadImage(){


    final stream = widget.image.resolve(

      createLocalImageConfiguration(context),

    );



    stream.addListener(

      ImageStreamListener(

            (info,_) {



          if(mounted){


            setState((){


              image = info.image;


            });


          }


        },

      ),

    );


  }







  @override
  Widget build(BuildContext context){


    return CustomPaint(



      size: Size(

        widget.size,

        widget.size,

      ),



      painter: PuzzlePainter(


        piece: widget.piece,


        cachedImage: image,


      ),



    );


  }



}








class PuzzlePainter extends CustomPainter {



  final PuzzlePiece piece;

  final ui.Image? cachedImage;



  PuzzlePainter({

    required this.piece,

    required this.cachedImage,

  });







  @override
  void paint(

      Canvas canvas,

      Size size,

      ){



    final path = createPiecePath(size);




    // الظل

    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black26

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          4,

        ),

    );






    if(cachedImage != null){



      canvas.save();



      canvas.clipPath(path);



      final source = Rect.fromLTWH(



        piece.sourceRect.left,

        piece.sourceRect.top,

        piece.sourceRect.width,

        piece.sourceRect.height,



      );






      canvas.drawImageRect(



        cachedImage!,

        source,

        Offset.zero & size,

        Paint()

          ..filterQuality = FilterQuality.high,



      );




      canvas.restore();



    }








    // حدود القطعة

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = piece.placed ? 3 : 1.5

        ..color = piece.placed

            ? Colors.green

            : Colors.white,



    );



  }








  Path createPiecePath(Size size){



    final path = Path();



    final w = size.width;

    final h = size.height;

    final tab = w * .22;





    path.moveTo(0,0);



    path.lineTo(

      w/2-tab,

      0,

    );



    drawEdge(

      path,

      piece.top,

      true,

      w/2,

      0,

      tab,

    );



    path.lineTo(

      w,

      0,

    );



    path.lineTo(

      w,

      h/2-tab,

    );



    drawEdge(

      path,

      piece.right,

      false,

      w,

      h/2,

      tab,

    );



    path.lineTo(

      w,

      h,

    );



    path.lineTo(

      w/2+tab,

      h,

    );



    drawEdge(

      path,

      piece.bottom,

      true,

      w/2,

      h,

      tab,

    );



    path.lineTo(

      0,

      h,

    );



    path.lineTo(

      0,

      h/2+tab,

    );



    drawEdge(

      path,

      piece.left,

      false,

      0,

      h/2,

      tab,

    );



    path.close();



    return path;


  }








  void drawEdge(

      Path path,

      EdgeType type,

      bool horizontal,

      double x,

      double y,

      double tab,

      ){



    if(type == EdgeType.flat){

      return;

    }




    final sign =

    type == EdgeType.tab ? -1 : 1;





    if(horizontal){



      path.cubicTo(

        x-tab,

        y+(tab*sign),

        x+tab,

        y+(tab*sign),

        x+tab,

        y,

      );



    }else{



      path.cubicTo(

        x+(tab*sign),

        y-tab,

        x+(tab*sign),

        y+tab,

        x,

        y+tab,

      );



    }



  }








  @override
  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate

      ){



    return oldDelegate.cachedImage != cachedImage ||

        oldDelegate.piece.position != piece.position ||

        oldDelegate.piece.placed != piece.placed;



  }



}