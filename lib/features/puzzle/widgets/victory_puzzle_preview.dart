import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';

class VictoryPieceRenderData {
  final PuzzlePiece piece;
  final Offset position;
  final double rotation;
  final double opacity;
  final double scale;

  const VictoryPieceRenderData({
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
  final int rows;
  final int cols;

  const VictoryPuzzlePreview({
    super.key,
    required this.image,
    required this.pieces,
    required this.rows,
    required this.cols,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _VictoryPuzzlePainter(
        image: image,
        pieces: pieces,
        rows: rows,
        cols: cols,
      ),
    );
  }
}

class _VictoryPuzzlePainter extends CustomPainter {
  final ui.Image image;
  final List<VictoryPieceRenderData> pieces;
  final int rows;
  final int cols;

  _VictoryPuzzlePainter({
    required this.image,
    required this.pieces,
    required this.rows,
    required this.cols,
  });

  final Paint _paint = Paint()
    ..filterQuality = FilterQuality.high;

  @override
  void paint(Canvas canvas, Size size) {

    if (pieces.isEmpty) return;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;


    // حساب حجم الصورة المجمعة
    for (final data in pieces) {
      final piece = data.piece;

      final x = data.position.dx;
      final y = data.position.dy;

      minX = math.min(minX, x);
      minY = math.min(minY, y);

      maxX = math.max(
        maxX,
        x + piece.localBounds.width,
      );

      maxY = math.max(
        maxY,
        y + piece.localBounds.height,
      );
    }


    final puzzleWidth = maxX - minX;
    final puzzleHeight = maxY - minY;


    // مركز الشاشة + رفع الصورة للأعلى
    final targetCenter = Offset(
      size.width / 2,
      size.height * 0.32,
    );


    final moveOffset = Offset(
      targetCenter.dx - (minX + puzzleWidth / 2),
      targetCenter.dy - (minY + puzzleHeight / 2),
    );


    for (final data in pieces) {

      final piece = data.piece;

      final w = piece.localBounds.width;
      final h = piece.localBounds.height;


      canvas.save();


      canvas.translate(
        data.position.dx + moveOffset.dx + w / 2,
        data.position.dy + moveOffset.dy + h / 2,
      );


      canvas.rotate(data.rotation);

      canvas.scale(data.scale);


      canvas.translate(
        -w / 2,
        -h / 2,
      );


      canvas.clipPath(piece.path);


      _paint.color = Colors.white.withOpacity(
        data.opacity.clamp(0.0, 1.0),
      );


      final source = Rect.fromLTWH(
        piece.col * (image.width / cols),
        piece.row * (image.height / rows),
        image.width / cols,
        image.height / rows,
      );


      canvas.drawImageRect(
        image,
        source,
        Rect.fromLTWH(
          0,
          0,
          w,
          h,
        ),
        _paint,
      );


      canvas.restore();
    }
  }


  @override
  bool shouldRepaint(
      covariant _VictoryPuzzlePainter oldDelegate) {
    return true;
  }
}