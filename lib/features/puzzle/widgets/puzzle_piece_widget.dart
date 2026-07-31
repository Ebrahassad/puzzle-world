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

  ImageStream? _imageStream;

  ImageStreamListener? _listener;

  bool _loaded = false;



  @override
  void didChangeDependencies() {

    super.didChangeDependencies();


    if (!_loaded) {

      _loadImage();

    }

  }



  @override
  void didUpdateWidget(
    covariant PuzzlePieceWidget oldWidget,
  ) {

    super.didUpdateWidget(oldWidget);


    if (
      oldWidget.image != widget.image ||
      oldWidget.size != widget.size
    ) {

      _loaded = false;

      cachedImage = null;

      _loadImage();

    }

  }




  void _loadImage() {


    if (
      _listener != null &&
      _imageStream != null
    ) {

      _imageStream!.removeListener(
        _listener!,
      );

    }



    final configuration =
        createLocalImageConfiguration(
          context,
          size: Size(
            widget.size,
            widget.size,
          ),
        );



    _imageStream =
        widget.image.resolve(
          configuration,
        );



    _listener = ImageStreamListener(

      (info, _) {

        if (!mounted) return;


        setState(() {

          cachedImage = info.image;

          _loaded = true;

        });

      },


      onError: (error, stackTrace) {

        debugPrint(
          "Puzzle image error: $error",
        );

      },

    );



    _imageStream!.addListener(
      _listener!,
    );

  }




  @override
  Widget build(
    BuildContext context,
  ) {


    Widget child;



    if (cachedImage == null) {


      child = SizedBox(

        width: widget.size,

        height: widget.size,

      );


    } else {


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


            // مهم للـ Painter الجديد

            pieceSize: widget.size,


            // مساحة النتوءات

            padding: widget.size * 0.10,

          ),

        ),

      );

    }



    return AnimatedScale(

      scale: widget.isActive
          ? 1.06
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


        curve: Curves.easeOut,


        child: child,

      ),

    );

  }




  @override
  void dispose() {


    if (
      _listener != null &&
      _imageStream != null
    ) {

      _imageStream!.removeListener(
        _listener!,
      );

    }


    super.dispose();

  }

}