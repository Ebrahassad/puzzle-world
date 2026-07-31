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
  State<PuzzlePieceWidget> createState() =>
      _PuzzlePieceWidgetState();

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


    if(!loaded){

      _loadImage();

    }

  }





  void _loadImage(){


    final configuration =
        createLocalImageConfiguration(
          context,
        );


    imageStream =
        widget.image.resolve(
          configuration,
        );



    listener = ImageStreamListener(

      (info, _) {


        if(!mounted) return;


        setState(() {

          imageCache = info.image;

          loaded = true;

        });


      },

      onError: (error, stack){

        debugPrint(
          "Puzzle image error: $error",
        );

      },

    );



    imageStream!.addListener(
      listener!,
    );


  }





  @override
  void didUpdateWidget(
      covariant PuzzlePieceWidget oldWidget,
      ){

    super.didUpdateWidget(oldWidget);


    if(
    oldWidget.image != widget.image ||
        oldWidget.size != widget.size
    ){

      _removeListener();

      imageCache = null;

      loaded = false;

      _loadImage();

    }

  }





  void _removeListener(){

    if(
    imageStream != null &&
        listener != null
    ){

      imageStream!.removeListener(
        listener!,
      );

    }

  }





  @override
  Widget build(BuildContext context){


    final child = imageCache == null

        ? SizedBox(
      width: widget.size,
      height: widget.size,
    )


        : CustomPaint(

      size: Size(
        widget.size,
        widget.size,
      ),


      painter: PuzzlePainter(

        piece: widget.piece,

        image: widget.image,

        cachedImage: imageCache,

      ),

    );





    return Positioned(

      left: widget.piece.position.dx,

      top: widget.piece.position.dy,


      child: GestureDetector(


        onPanStart: (_) {

          widget.onDragStart?.call(
            widget.piece,
          );

        },


        onPanUpdate: (details){

          widget.onDragUpdate?.call(
            details.delta,
          );

        },


        onPanEnd: (_) {

          widget.onDragEnd?.call();

        },


        child: AnimatedScale(

          scale: widget.active
              ? 1.06
              : 1.0,


          duration:
          const Duration(
            milliseconds: 150,
          ),


          child: AnimatedOpacity(

            opacity:

            widget.piece.state ==
                PieceState.locked

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





  @override
  void dispose(){

    _removeListener();

    super.dispose();

  }


}