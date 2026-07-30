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
    extends State<PuzzlePieceWidget> {


  ui.Image? cachedImage;


  ImageStream? imageStream;


  ImageStreamListener? listener;




  @override
  void didChangeDependencies() {

    super.didChangeDependencies();

    _loadImage();

  }





  @override
  void didUpdateWidget(

    covariant PuzzlePieceWidget oldWidget,

  ) {


    super.didUpdateWidget(oldWidget);



    if (oldWidget.image != widget.image) {

      _loadImage();

    }

  }





  void _loadImage() {


    if (listener != null && imageStream != null) {

      imageStream!.removeListener(listener!);

    }



    imageStream = widget.image.resolve(

      createLocalImageConfiguration(

        context,

      ),

    );



    listener = ImageStreamListener(

      (info, _) {


        if (!mounted) return;



        setState(() {


          cachedImage = info.image;


        });


      },


      onError: (error, stackTrace) {


        debugPrint(

          "Puzzle image error: $error",

        );


      },

    );



    imageStream!.addListener(listener!);

  }





  @override
  Widget build(BuildContext context) {


    if (cachedImage == null) {


      return SizedBox(

        width: widget.size,

        height: widget.size,

      );

    }



    return RepaintBoundary(


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
  @override
  void dispose() {


    if (listener != null && imageStream != null) {


      imageStream!.removeListener(

        listener!,

      );


    }


    super.dispose();

  }


}