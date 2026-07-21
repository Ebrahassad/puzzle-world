import 'package:flutter/material.dart';

import '../puzzle_engine/puzzle_piece.dart';
import '../puzzle_engine/puzzle_painter.dart';



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
  Widget build(BuildContext context) {


    return SizedBox(


      width:size,


      height:size,


      child:CustomPaint(


        painter:PuzzlePainter(


          piece:piece,


          image:image,


        ),


      ),


    );


  }


}
