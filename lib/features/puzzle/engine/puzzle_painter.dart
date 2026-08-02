import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';

/// Paints every [PuzzlePiece] of a jigsaw puzzle onto the canvas.
///
/// For each piece, in ascending [PuzzlePiece.zOrder]:
///  1. Translate the canvas origin to the piece's current on-screen
///     position ([PuzzlePiece.currentPosition]).
///  2. Clip to the piece's exact Bézier outline ([PuzzlePiece.path]).
///  3. Draw the *entire* source image via [Canvas.drawImageRect], shifted so
///     the piece's own cell lines up with the local origin. Because the
///     canvas is already clipped to the piece's silhouette, only the pixels
///     inside that silhouette are actually painted — which is exactly what
///     lets a tab "borrow" image content from the neighbouring cell and
///     keeps the picture continuous across every seam, with no cropping.
///  4. Stroke a subtle outline so pieces read as separate physical objects,
///     and draw a soft drop shadow under whichever piece is currently being
///     dragged, for a tactile "picked up" feel.
class PuzzlePainter extends CustomPainter {
  PuzzlePainter({
    required this.pieces,
    required this.image,
    required this.boardRect,
    required this.rows,
    required this.cols,
    Listenable? repaint,
  })  : pieceWidth = boardRect.width / cols,
        pieceHeight = boardRect.height / rows,
        super(repaint: repaint);

  final List<PuzzlePiece> pieces;
  final ui.Image image;
  final Rect boardRect;
  final int rows;
  final int cols;
  final double pieceWidth;
  final double pieceHeight;

  static final Paint _borderPaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.4
  ..color = const Color(0x55000000);

  static final Paint _imagePaint = Paint()..filterQuality = FilterQuality.high;

  static final Paint _boardOutlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0x22000000);

  static final Paint _shadowPaint = Paint()
  ..color = const Color(0x66000000)
  ..maskFilter = const MaskFilter.blur(
    BlurStyle.normal,
    8,
  );

static final Paint _highlightPaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.2
  ..color = const Color(0x33FFFFFF);



  @override
  void paint(Canvas canvas, Size size) {
    // Faint frame showing where the finished puzzle belongs, so players
    // have a reference while pieces are still scattered.
    canvas.drawRect(boardRect, _boardOutlinePaint);

    // Paint back-to-front in zOrder so the most recently picked up piece(s)
    // always render on top of their neighbours.
    final ordered = List<PuzzlePiece>.of(pieces)
      ..sort((a, b) => a.zOrder.compareTo(b.zOrder));

    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    for (final piece in ordered) {
      if (piece.isDragging) {
  _paintShadow(canvas, piece);
}
      canvas.save();

final lift = piece.isDragging ? -6.0 : 0.0;

canvas.translate(
  piece.currentPosition.dx,
  piece.currentPosition.dy + lift,
);

canvas.clipPath(piece.path);

      // Shift the whole image so that this piece's cell (col, row) lands
      // exactly on the local origin. The clip (set above) then reveals only
      // the pixels within this piece's silhouette, including whatever
      // overshoots into a neighbouring cell via a tab.
      final destRect = Rect.fromLTWH(
        -piece.col * pieceWidth,
        -piece.row * pieceHeight,
        boardRect.width,
        boardRect.height,
      );
      canvas.drawImageRect(
  image,
  srcRect,
  destRect,
  _imagePaint,
);

// حافة داكنة لكل القطع
canvas.drawPath(
  piece.path,
  _borderPaint,
);

// لمعة فقط للقطع غير المثبتة
if (!piece.isPlaced) {
  canvas.drawPath(
    piece.path,
    _highlightPaint,
  );
}

canvas.restore();
    }
  }

  void _paintShadow(Canvas canvas, PuzzlePiece piece) {
  canvas.save();

  canvas.translate(
    piece.currentPosition.dx + 4,
    piece.currentPosition.dy + 8,
  );

  canvas.drawPath(
    piece.path,
    _shadowPaint,
  );

  canvas.restore();
}

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.pieces != pieces ||
        oldDelegate.image != image ||
        oldDelegate.boardRect != boardRect;
  }
}