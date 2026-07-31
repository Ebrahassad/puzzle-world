import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';
import '../engine/puzzle_painter.dart';


class PuzzlePieceWidget extends StatefulWidget {

  final PuzzlePiece piece;

  final ImageProvider image;

  final double size;


  final bool isActive;

  final double opacity;



  const PuzzlePieceWidget({

    super.key,

    required this.piece,

    required this.image,

    required this.size,

    this.isActive = false,

    this.opacity = 1.0,

  });



  @override
  State<PuzzlePieceWidget> createState() =>
      _PuzzlePieceWidgetState();

}






class _PuzzlePieceWidgetState

    extends State<PuzzlePieceWidget> {



  ui.Image? cachedImage;


  ImageStream? _stream;


  ImageStreamListener? _listener;



  bool loaded = false;






  @override
  void didChangeDependencies() {

    super.didChangeDependencies();


    if(!loaded){

      _loadImage();

    }

  }








  @override
  void didUpdateWidget(

    covariant PuzzlePieceWidget oldWidget,

  ){

    super.didUpdateWidget(oldWidget);



    if(oldWidget.image != widget.image){


      _removeListener();



      cachedImage = null;


      loaded = false;


      _loadImage();


    }


  }









  void _loadImage(){



    final configuration =

        createLocalImageConfiguration(

          context,

          size: Size(

            widget.size,

            widget.size,

          ),

        );



    _stream = widget.image.resolve(

      configuration,

    );




    _listener = ImageStreamListener(

      (info, synchronousCall){


        if(!mounted) return;



        setState((){


          cachedImage = info.image;


          loaded = true;



        });



      },


      onError: (error, stackTrace){


        debugPrint(

          "Puzzle image loading error: $error",

        );


      },


    );




    _stream!.addListener(

      _listener!,

    );


  }









  void _removeListener(){


    if(_listener != null &&

       _stream != null){



      _stream!.removeListener(

        _listener!,

      );

    }


  }










  @override
  Widget build(

    BuildContext context,

  ){



    Widget child;



    if(cachedImage == null){



      child = SizedBox(

        width: widget.size,

        height: widget.size,

      );



    }

    else {



      child = RepaintBoundary(


        child: CustomPaint(


          size: Size(

            widget.size,

            widget.size,

          ),



          painter: PuzzlePainter(


            piece: widget.piece,


            image: widget.image,


            cachedImage: cachedImage,


          ),


        ),


      );


    }






    return AnimatedScale(

      scale:

          widget.isActive

              ? 1.08

              : 1.0,


      duration:

          const Duration(

            milliseconds: 140,

          ),


      curve:

          Curves.easeOutCubic,



      child: AnimatedOpacity(


        opacity: widget.opacity,


        duration:

            const Duration(

              milliseconds: 120,

            ),



        child: child,

      ),

    );


  }









  @override
  void dispose(){


    _removeListener();


    super.dispose();

  }


}