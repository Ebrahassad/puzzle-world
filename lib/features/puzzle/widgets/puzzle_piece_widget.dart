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



  ImageInfo? imageInfo;






  @override
  void didChangeDependencies(){


    super.didChangeDependencies();


    loadImage();


  }








  void loadImage(){



    final stream =

    widget.image.resolve(

      createLocalImageConfiguration(context),

    );






    stream.addListener(



      ImageStreamListener(

            (info,_){



          if(mounted){



            setState((){



              imageInfo = info;



            });



          }



        },

      ),



    );



  }









  @override
  Widget build(BuildContext context){



    return CustomPaint(



      size:

      Size(

        widget.size,

        widget.size,

      ),





      painter:

      PuzzlePiecePainter(



        piece:

        widget.piece,



        imageInfo:

        imageInfo,



      ),



    );



  }



}









class PuzzlePiecePainter extends CustomPainter {



  final PuzzlePiece piece;

  final ImageInfo? imageInfo;






  PuzzlePiecePainter({

    required this.piece,

    required this.imageInfo,

  });









  @override

  void paint(

      Canvas canvas,

      Size size,

      ){



    final image = imageInfo?.image;



    if(image == null){



      return;



    }







    final paint = Paint()

      ..filterQuality = FilterQuality.high;






    canvas.drawImageRect(



      image,



      piece.sourceRect,



      Offset.zero & size,



      paint,



    );







    // إطار خفيف للقطعة

    canvas.drawRect(



      Offset.zero & size,



      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = piece.placed ? 3 : 1

        ..color = piece.placed

            ? Colors.greenAccent

            : Colors.white,



    );



  }









  @override

  bool shouldRepaint(

      covariant PuzzlePiecePainter oldDelegate

      ){



    return oldDelegate.imageInfo != imageInfo ||

        oldDelegate.piece != piece;



  }



}