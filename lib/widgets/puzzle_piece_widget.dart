import 'package:flutter/material.dart';

import '../puzzle_engine/puzzle_piece.dart';
import '../puzzle_engine/puzzle_painter.dart';



class PuzzlePieceWidget extends StatelessWidget {


  final PuzzlePiece piece;


  final ImageProvider image;


  final double size;


  final VoidCallback? onTap;



  const PuzzlePieceWidget({

    super.key,

    required this.piece,

    required this.image,

    required this.size,

    this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return GestureDetector(


      onTap:onTap,



      child:AnimatedContainer(


        duration:
        const Duration(milliseconds:150),


        width:size,


        height:size,



        child:CustomPaint(



          painter:PuzzlePainter(



            piece:piece,



            image:image,



          ),



        ),


      ),


    );


  }

}