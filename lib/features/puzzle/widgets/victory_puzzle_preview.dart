import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';

class VictoryPuzzlePreview extends StatelessWidget {
  final ui.Image image;
  final List<PuzzlePiece> pieces;

  const VictoryPuzzlePreview({
    super.key,
    required this.image,
    required this.pieces,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _VictoryPuzzlePainter(
        pieces: pieces,
        image: image,
      ),
    );
  }
}


class _VictoryPuzzlePainter extends CustomPainter {

  final List<PuzzlePiece> pieces;
  final ui.Image image;

  _VictoryPuzzlePainter({
    required this.pieces,
    required this.image,
  });

  final Paint _paint = Paint()
    ..filterQuality = FilterQuality.high;


  @override
  void paint(Canvas canvas, Size size) {

    for (final piece in pieces) {

      canvas.save();

      canvas.translate(
        piece.correctPosition.dx,
        piece.correctPosition.dy,
      );

      canvas.clipPath(piece.path);


      final source = Rect.fromLTWH(
        piece.col *
            (image.width / _getCols()),
        piece.row *
            (image.height / _getRows()),
        image.width / _getCols(),
        image.height / _getRows(),
      );


      canvas.drawImageRect(
        image,
        source,
        Rect.fromLTWH(
          0,
          0,
          piece.width,
          piece.height,
        ),
        _paint,
      );


      canvas.restore();
    }
  }


  int _getCols() {
    return pieces.map((e) => e.col).reduce((a,b)=>a>b?a:b)+1;
  }

  int _getRows() {
    return pieces.map((e) => e.row).reduce((a,b)=>a>b?a:b)+1;
  }


  @override
  bool shouldRepaint(
      covariant _VictoryPuzzlePainter oldDelegate) {
    return true;
  }
}