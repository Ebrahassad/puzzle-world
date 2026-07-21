import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';



class PuzzlePieceWidget extends StatelessWidget {


  final PuzzlePiece piece;


  final double size;



  const PuzzlePieceWidget({


    super.key,


    required this.piece,


    required this.size,


  });






  @override
  Widget build(BuildContext context) {



    return Container(



      width:size,


      height:size,



      decoration:

      BoxDecoration(



        color:Colors.white,



        borderRadius:

        BorderRadius.circular(12),



        boxShadow:[



          BoxShadow(



            color:

            Colors.black.withOpacity(.25),



            blurRadius:8,



            offset:

            const Offset(0,5),



          ),



        ],



      ),



      child:

      ClipRRect(



        borderRadius:

        BorderRadius.circular(12),



        child:

        CustomPaint(



          size:

          Size(size,size),



          painter:

          PuzzlePiecePainter(



            piece:piece,



          ),



        ),



      ),



    );



  }


}







class PuzzlePiecePainter extends CustomPainter {



  final PuzzlePiece piece;



  PuzzlePiecePainter({


    required this.piece,


  });






  @override

  void paint(

      Canvas canvas,

      Size size,

      ){



    final paint = Paint()



      ..color = Colors.blueAccent



      ..style = PaintingStyle.fill;






    final path = Path();



    path.addRect(

      Rect.fromLTWH(

        0,

        0,

        size.width,

        size.height,

      ),

    );



    canvas.drawPath(

      path,

      paint,

    );




    // رقم القطعة للمساعدة أثناء التطوير

    final textPainter = TextPainter(



      text:

      TextSpan(



        text:

        "${piece.id}",



        style:

        const TextStyle(



          color:Colors.white,


          fontSize:18,


          fontWeight:

          FontWeight.bold,


        ),



      ),



      textDirection:

      TextDirection.rtl,



    );



    textPainter.layout();



    textPainter.paint(



      canvas,



      Offset(



        (size.width -

            textPainter.width) /

            2,



        (size.height -

            textPainter.height) /

            2,



      ),



    );



  }







  @override

  bool shouldRepaint(

      covariant CustomPainter oldDelegate,

      ){


    return true;


  }



}
