import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';
import '../engine/puzzle_painter.dart';





class PuzzlePieceWidget extends StatefulWidget {


  final PuzzlePiece piece;


  final ImageProvider image;


  final double size;


  final bool active;


  final Function(PuzzlePiece)? onDragStart;


  final Function(Offset)? onDragUpdate;


  final VoidCallback? onDragEnd;





  const PuzzlePieceWidget({

    super.key,


    required this.piece,


    required this.image,


    required this.size,


    this.active = false,


    this.onDragStart,


    this.onDragUpdate,


    this.onDragEnd,

  });







  @override
  State<PuzzlePieceWidget> createState()

      => _PuzzlePieceWidgetState();

}







class _PuzzlePieceWidgetState

    extends State<PuzzlePieceWidget> {



  ui.Image? imageCache;



  ImageStream? imageStream;



  ImageStreamListener? listener;



  bool loaded = false;






  @override
  void didChangeDependencies() {


    super.didChangeDependencies();



    if(!loaded) {


      _loadImage();


    }

  }


  //==================================================
  // تحميل الصورة
  //==================================================

  void _loadImage() {


    final configuration =

        createLocalImageConfiguration(

          context,

          size: Size(

            widget.size,

            widget.size,

          ),

        );



    imageStream =

        widget.image.resolve(

          configuration,

        );





    listener = ImageStreamListener(

      (

        info,

        synchronousCall,

      ) {



        if(!mounted) return;



        setState(() {


          imageCache = info.image;


          loaded = true;


        });


      },


      onError:

          (

            error,

            stack,

          ) {


        debugPrint(

          "Puzzle image error: $error",

        );


      },


    );





    imageStream!.addListener(

      listener!,

    );


  }







  //==================================================
  // تحديث الصورة
  //==================================================

  @override
  void didUpdateWidget(

    covariant PuzzlePieceWidget oldWidget,

  ) {


    super.didUpdateWidget(

      oldWidget,

    );



    if(

      oldWidget.image != widget.image

      ||

      oldWidget.size != widget.size

    ) {



      _removeListener();



      imageCache = null;


      loaded = false;


      _loadImage();


    }

  }






  //==================================================
  // إزالة مستمع الصورة
  //==================================================

  void _removeListener() {


    if(

      imageStream != null

      &&

      listener != null

    ) {


      imageStream!

          .removeListener(

            listener!,

          );


    }

  }


  //==================================================
  // بناء القطعة
  //==================================================

  @override
  Widget build(

    BuildContext context,

  ) {



    Widget child;



    if(imageCache == null) {


      child = SizedBox(

        width:

            widget.size,


        height:

            widget.size,

      );


    }

    else {



      child = CustomPaint(

        size: Size(

          widget.size,

          widget.size,

        ),



        painter:

            PuzzlePainter(

              piece:

                  widget.piece,


              image:

                  imageCache!,

            ),

      );


    }







    return Positioned(

      left:

          widget.piece.x,


      top:

          widget.piece.y,



      child: GestureDetector(

        onPanStart:

            (_) {


          widget.onDragStart?.call(

            widget.piece,

          );


        },




        onPanUpdate:

            (details) {


          widget.onDragUpdate?.call(

            details.delta,

          );


        },




        onPanEnd:

            (_) {


          widget.onDragEnd?.call();


        },



        child: AnimatedScale(

          scale:

              widget.active

                  ? 1.06

                  : 1.0,



          duration:

              const Duration(

                milliseconds: 150,

              ),



          child: AnimatedOpacity(

            opacity:

                widget.piece.placed

                    ? 0.95

                    : 1.0,



            duration:

                const Duration(

                  milliseconds: 120,

                ),



            child: child,

          ),

        ),

      ),

    );

  }








  //==================================================
  // تنظيف الموارد
  //==================================================

  @override
  void dispose() {


    _removeListener();


    super.dispose();

  }


}