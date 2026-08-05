import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';

class VictoryPuzzlePreview extends StatelessWidget {
  final List<PuzzlePiece> pieces;
  final ui.Image image;
  final Rect boardRect;
  final int rows;
  final int cols;

  const VictoryPuzzlePreview({
    super.key,
    required this.pieces,
    required this.image,
    required this.boardRect,
    required this.rows,
    required this.cols,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        boardRect.width,
        boardRect.height,
      ),
      painter: VictoryPuzzlePainter(
        pieces: pieces,
        image: image,
        boardRect: boardRect,
        rows: rows,
        cols: cols,
      ),
    );
  }
}


class VictoryPuzzlePainter extends CustomPainter {

  final List<PuzzlePiece> pieces;
  final ui.Image image;
  final Rect boardRect;
  final int rows;
  final int cols;


  VictoryPuzzlePainter({
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


    final pieceWidth = boardRect.width / cols;
    final pieceHeight = boardRect.height / rows;


    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );


    for(final piece in pieces){


      canvas.save();


      canvas.translate(
        piece.currentPosition.dx - boardRect.left,
        piece.currentPosition.dy - boardRect.top,
      );


      canvas.clipPath(piece.path);


      final dest = Rect.fromLTWH(
        -piece.col * pieceWidth,
        -piece.row * pieceHeight,
        boardRect.width,
        boardRect.height,
      );


      canvas.drawImageRect(
        image,
        src,
        dest,
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
    covariant VictoryPuzzlePainter oldDelegate,
  ){
    return true;
  }

}