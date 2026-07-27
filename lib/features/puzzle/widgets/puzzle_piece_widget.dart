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


  late ImageStream imageStream;



  late AnimationController _glowController;


  late Animation<double> _glowAnimation;





  @override
  void initState(){

    super.initState();


    _loadImage();



    _glowController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:2),

    );


    _glowAnimation = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:_glowController,

        curve:Curves.easeInOut,

      ),

    );



    if(widget.piece.placed){

      _glowController.repeat(

        reverse:true,

      );

    }


  }







  void _loadImage(){


    imageStream = widget.image.resolve(

      const ImageConfiguration(),

    );


    imageStream.addListener(

      ImageStreamListener(

            (info, synchronousCall){


          if(mounted){

            setState((){

              loadedImage = info.image;

            });

          }


        },

      ),

    );


  }







  @override
  void didUpdateWidget(
      covariant PuzzlePieceWidget oldWidget){

    super.didUpdateWidget(oldWidget);


    if(oldWidget.image != widget.image){

      _loadImage();

    }



    if(widget.piece.placed &&
        !oldWidget.piece.placed){


      _glowController.repeat(

        reverse:true,

      );


    }


  }







  void setPressed(bool value){


    if(widget.piece.placed){

      return;

    }


    setState((){

      pressed=value;

    });


  }







  @override
  void dispose(){


    _glowController.dispose();


    imageStream.removeListener(

      ImageStreamListener(

            (_,__){},

      ),

    );


    super.dispose();


  }







  @override
  Widget build(BuildContext context){



    final placed =
        widget.piece.placed;



    return RepaintBoundary(


      child:GestureDetector(


        onTapDown:(_){

          setPressed(true);

        },


        onTapUp:(_){

          setPressed(false);

        },


        onTapCancel:(){

          setPressed(false);

        },



        child:AnimatedScale(


          scale:

          pressed ? 1.04 : 1,


          duration:

          const Duration(

            milliseconds:120,

          ),



          child:CustomPaint(


            size:

            Size(

              widget.size,

              widget.size,

            ),



            painter:

            PuzzlePainter(


              piece:

              widget.piece,


              image:

              widget.image,


              cachedImage:

              loadedImage,


            ),


          ),


        ),


      ),


    );


  }


}