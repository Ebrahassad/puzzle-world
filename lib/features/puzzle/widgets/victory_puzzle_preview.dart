import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';


/// Data used only for victory cinematic rendering.
/// Does not modify the real puzzle engine.
class VictoryPieceRenderData {
  final PuzzlePiece piece;

  final Offset position;
  final double rotation;
  final double opacity;
  final double scale;

  VictoryPieceRenderData({
    required this.piece,
    required this.position,
    required this.rotation,
    required this.opacity,
    required this.scale,
  });
}



class VictoryPuzzlePreview extends StatelessWidget {

  final ui.Image image;

  final List<VictoryPieceRenderData> pieces;


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


  final List<VictoryPieceRenderData> pieces;

  final ui.Image image;


  _VictoryPuzzlePainter({
    required this.pieces,
    required this.image,
  });



  final Paint _paint = Paint()
    ..filterQuality = FilterQuality.high;



  @override
  void paint(Canvas canvas, Size size) {


    for (final data in pieces) {


      final piece = data.piece;


      canvas.save();



      // Current animated position
      canvas.translate(
        data.position.dx,
        data.position.dy,
      );



      // Explosion rotation
      canvas.rotate(
        data.rotation,
      );



      // Explosion scale
      canvas.scale(
        data.scale,
        data.scale,
      );



      // Fade animation
      _paint.opacity = data.opacity;



      canvas.clipPath(
        piece.path,
      );



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

    return pieces
            .map((e) => e.piece.col)
            .reduce((a, b) => a > b ? a : b) +
        1;

  }




  int _getRows() {

    return pieces
            .map((e) => e.piece.row)
            .reduce((a, b) => a > b ? a : b) +
        1;

  }




  @override
  bool shouldRepaint(
      covariant _VictoryPuzzlePainter oldDelegate) {

    return true;

  }

}