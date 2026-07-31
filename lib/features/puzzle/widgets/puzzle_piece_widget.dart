import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';

import 'puzzle_painter.dart';




///======================================================
/// Widget مسؤول عن عرض قطعة البازل والتحكم باللمس
///======================================================

class PuzzlePieceWidget extends StatefulWidget {


  final PuzzlePiece piece;


  final ImageProvider image;


  final double size;


  final bool active;



  final Function(PuzzlePiece)? onDragStart;


  final Function(Offset)? onDragUpdate;


  final Function()? onDragEnd;



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





  //====================================================
  // تحميل الصورة مرة واحدة
  //====================================================

  void _loadImage() {


    final configuration =

        createLocalImageConfiguration(

          context,

        );



    imageStream =

        widget.image.resolve(

          configuration,

        );



    listener = ImageStreamListener(

      (info, synchronousCall) {


        if(!mounted) return;



        setState(() {


          imageCache = info.image;


          loaded = true;


        });


      },

    );



    imageStream!.addListener(

      listener!,

    );

  }





  //====================================================
  // بناء القطعة
  //====================================================

  @override
  Widget build(

    BuildContext context,

  ) {


    if(imageCache == null) {


      return SizedBox(

        width: widget.size,

        height: widget.size,

      );


    }



    return Positioned(

      left: widget.piece.position.dx,

      top: widget.piece.position.dy,


      child: GestureDetector(


        onPanStart: (details) {


          widget.onDragStart?.call(

            widget.piece,

          );


        },



        onPanUpdate: (details) {


          widget.onDragUpdate?.call(

            details.globalPosition,

          );


        },



        onPanEnd: (_) {


          widget.onDragEnd?.call();


        },



        child: AnimatedScale(

          scale:

              widget.active

              ? 1.05

              : 1.0,


          duration:

              const Duration(

                milliseconds:120,

              ),


          child: CustomPaint(

            size:

                Size(

                  widget.size,

                  widget.size,

                ),


            painter:

                PuzzlePainter(

                  piece: widget.piece,

                  image: imageCache!,

                ),

          ),

        ),

      ),

    );

  }

  //====================================================
  // تحديث القطعة عند تغير الصورة أو البيانات
  //====================================================

  @override
  void didUpdateWidget(

    covariant PuzzlePieceWidget oldWidget,

  ) {


    super.didUpdateWidget(

      oldWidget,

    );



    if (

      oldWidget.image != widget.image

      ||

      oldWidget.size != widget.size

    ) {


      _removeImageListener();



      imageCache = null;


      loaded = false;


      _loadImage();


    }

  }





  //====================================================
  // إزالة مستمع الصورة
  //====================================================

  void _removeImageListener() {


    if (

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





  //====================================================
  // تنظيف الموارد
  //====================================================

  @override
  void dispose() {


    _removeImageListener();


    super.dispose();

  }


}