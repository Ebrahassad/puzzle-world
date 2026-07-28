import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';
import '../engine/puzzle_painter.dart';



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


            (info,_){



          if(mounted){


            setState((){


              image = info.image;


            });


          }


        },



        onError:(error,stackTrace){


          debugPrint(

            "Puzzle image error: $error",

          );


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



        image: widget.image,



        cachedImage: image,



      ),



    );


  }



}