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


  bool pressed = false;


  ui.Image? loadedImage;


  ImageStream? imageStream;



  late AnimationController glowController;


  late Animation<double> glowAnimation;






  @override
  void initState(){

    super.initState();


    loadImage();



    glowController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:2),

    );



    glowAnimation = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent: glowController,

        curve: Curves.easeInOut,

      ),

    );



    if(widget.piece.placed){

      glowController.repeat(

        reverse:true,

      );

    }


  }








  void loadImage(){



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


      loadImage();


    }




    if(widget.piece.placed &&

        !oldWidget.piece.placed){


      glowController.repeat(

        reverse:true,

      );


    }


  }








  void setPressed(bool value){


    if(widget.piece.placed){

      return;

    }



    setState((){

      pressed = value;

    });


  }








  @override
  void dispose(){



    glowController.dispose();



    if(imageStream != null){


      imageStream!.addListener(

        ImageStreamListener(

              (_,__){},

        ),

      );


    }



    super.dispose();

  }









  @override
  Widget build(BuildContext context){



    return RepaintBoundary(


      child: GestureDetector(


        onTapDown:(_){

          setPressed(true);

        },


        onTapUp:(_){

          setPressed(false);

        },


        onTapCancel:(){

          setPressed(false);

        },



        child: AnimatedScale(


          scale: pressed ? 1.05 : 1,



          duration:

          const Duration(

            milliseconds:120,

          ),



          child: CustomPaint(



            size: Size(

              widget.size,

              widget.size,

            ),




            painter: PuzzlePainter(



              piece: widget.piece,



              image: widget.image,



              cachedImage: loadedImage,



            ),



          ),



        ),



      ),



    );


  }


}