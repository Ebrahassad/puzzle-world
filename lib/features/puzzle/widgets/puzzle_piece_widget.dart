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
    extends State<PuzzlePieceWidget>
    with SingleTickerProviderStateMixin {



  ui.Image? loadedImage;


  ImageStream? imageStream;


  bool pressed = false;


  late AnimationController glowController;







  @override
  void initState(){

    super.initState();


    _loadImage();



    glowController = AnimationController(

      vsync:this,

      duration:const Duration(seconds:2),

    );



    if(widget.piece.placed){

      glowController.repeat(

        reverse:true,

      );

    }


  }









  void _loadImage(){


    final stream = widget.image.resolve(

      const ImageConfiguration(),

    );


    imageStream = stream;



    stream.addListener(

      ImageStreamListener(

            (info, synchronousCall){


          if(!mounted){

            return;

          }



          setState((){

            loadedImage = info.image;

          });


        },

      ),

    );


  }









  @override
  void didUpdateWidget(

      covariant PuzzlePieceWidget oldWidget,

      ){


    super.didUpdateWidget(oldWidget);



    if(oldWidget.image != widget.image){

      _loadImage();

    }




    if(widget.piece.placed &&

        !oldWidget.piece.placed){


      glowController.repeat(

        reverse:true,

      );


    }


  }









  @override
  void dispose(){


    glowController.dispose();


    super.dispose();

  }









  @override
  Widget build(BuildContext context){


    return RepaintBoundary(


      child:GestureDetector(


        onTapDown:(_){


          if(!widget.piece.placed){


            setState((){

              pressed = true;

            });


          }


        },



        onTapUp:(_){


          if(mounted){

            setState((){

              pressed=false;

            });

          }


        },



        onTapCancel:(){


          if(mounted){

            setState((){

              pressed=false;

            });

          }


        },



        child:AnimatedScale(


          scale: pressed ? 1.05 : 1,


          duration:

          const Duration(

            milliseconds:120,

          ),




          child:CustomPaint(


            size:Size(

              widget.size,

              widget.size,

            ),



            painter:PuzzlePainter(


              piece:widget.piece,


              image:widget.image,


              cachedImage:loadedImage,


            ),



          ),



        ),



      ),


    );


  }


}