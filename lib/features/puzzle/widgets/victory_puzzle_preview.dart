import 'dart:ui' as ui;
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
        image: image,
        pieces: pieces,
      ),
    );
  }
}

class _VictoryPuzzlePainter extends CustomPainter {
  final ui.Image image;
  final List<VictoryPieceRenderData> pieces;

  _VictoryPuzzlePainter({
    required this.image,
    required this.pieces,
  });

  final Paint _paint = Paint()
    ..filterQuality = FilterQuality.high;

  @override
  void paint(Canvas canvas, Size size) {
    for (final data in pieces) {
      final piece = data.piece;

      final w = piece.localBounds.width;
      final h = piece.localBounds.height;

      canvas.save();

      canvas.translate(
        data.position.dx + w / 2,
        data.position.dy + h / 2,
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
        piece.sourceRect.left,
        piece.sourceRect.top,
        piece.sourceRect.width,
        piece.sourceRect.height,
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
