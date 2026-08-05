import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';


class VictoryPuzzlePreview extends StatelessWidget {

  final ui.Image image;
  final int rows;
  final int cols;
  final Rect boardRect;


  const VictoryPuzzlePreview({
    super.key,
    required this.image,
    required this.rows,
    required this.cols,
    required this.boardRect,
  });


  @override
  Widget build(BuildContext context) {


    final pieces = PuzzleGenerator.generate(
      image: image,
      rows: rows,
      cols: cols,
      boardRect: Rect.fromLTWH(
        0,
        0,
        boardRect.width,
        boardRect.height,
      ),
      scatterArea: Rect.fromLTWH(
        0,
        0,
        boardRect.width,
        boardRect.height,
      ),
      seed: 1,
    );


    // تثبيت القطع في مكان الحل
    for (final piece in pieces) {
      piece.currentPosition = piece.correctPosition;
    }


    return SizedBox(
      width: boardRect.width,
      height: boardRect.height,

      child: CustomPaint(

        painter: _VictoryPuzzlePainter(
          pieces: pieces,
          image: image,
          boardRect: Rect.fromLTWH(
            0,
            0,
            boardRect.width,
            boardRect.height,
          ),
          rows: rows,
          cols: cols,
        ),

      ),
    );
  }
}



class _VictoryPuzzlePainter extends CustomPainter {


  final List<PuzzlePiece> pieces;
  final ui.Image image;
  final Rect boardRect;
  final int rows;
  final int cols;



  _VictoryPuzzlePainter({
    required this.pieces,
    required this.image,
    required this.boardRect,
    required this.rows,
    required this.cols,
  });



  final Paint _imagePaint = Paint()
    ..filterQuality = FilterQuality.high;



  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..color = const Color(0x22000000);



  @override
  void paint(Canvas canvas, Size size) {


    final pieceWidth =
        boardRect.width / cols;


    final pieceHeight =
        boardRect.height / rows;



    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );



    for (final piece in pieces) {


      canvas.save();


      // موقع القطعة داخل لوحة النصر
      canvas.translate(
        piece.col * pieceWidth,
        piece.row * pieceHeight,
      );



      canvas.clipPath(
        piece.path,
      );



      final destination = Rect.fromLTWH(
        -piece.col * pieceWidth,
        -piece.row * pieceHeight,
        boardRect.width,
        boardRect.height,
      );



      canvas.drawImageRect(
        image,
        source,
        destination,
        _imagePaint,
      );



      canvas.drawPath(
        piece.path,
        _borderPaint,
      );



      canvas.restore();
    }

  }



  @override
  bool shouldRepaint(
    covariant _VictoryPuzzlePainter oldDelegate,
  ) {

    return true;

  }

}