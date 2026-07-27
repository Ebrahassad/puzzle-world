import 'package:flutter/material.dart';
import '../engine/puzzle_piece.dart';


class PuzzlePieceWidget extends StatelessWidget {


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
  Widget build(BuildContext context){


    return CustomPaint(


      size:Size(
        size,
        size,
      ),


      painter:PuzzlePiecePainter(

        piece:piece,

        image:image,

      ),


    );


  }



}








class PuzzlePiecePainter extends CustomPainter {



  final PuzzlePiece piece;

  final ImageProvider image;



  ImageStream? stream;

  ImageInfo? imageInfo;



  PuzzlePiecePainter({

    required this.piece,

    required this.image,

  });






  @override
  void paint(Canvas canvas,Size size){



    final paint = Paint();



    final imageRect = Rect.fromLTWH(

      0,

      0,

      size.width,

      size.height,

    );



    final src = piece.sourceRect;



    final img = imageInfo?.image;



    if(img != null){


      canvas.drawImageRect(

        img,

        src,

        imageRect,

        paint,

      );


    }else{


      paint.color = Colors.grey;


      canvas.drawRect(

        imageRect,

        paint,

      );


    }



  }







  @override
  bool shouldRepaint(

      covariant PuzzlePiecePainter oldDelegate

      ){

    return true;

  }




}