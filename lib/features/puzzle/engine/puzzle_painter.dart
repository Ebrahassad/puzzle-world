import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'puzzle_piece.dart';

class PuzzlePainter extends CustomPainter {
  PuzzlePainter({
    required this.pieces,
    required this.image,
    required this.boardRect,
    required this.scatterArea,
    required this.rows,
    required this.cols,
    required this.trayOffset,
    Listenable? repaint,
  })  : pieceWidth = boardRect.width / cols,
        pieceHeight = boardRect.height / rows,
        super(repaint: repaint);

  final List<PuzzlePiece> pieces;
  final ui.Image image;
  final Rect boardRect;
  final Rect scatterArea;
  final int rows;
  final int cols;
  final double pieceWidth;
  final double pieceHeight;
  final double trayOffset;

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
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  static final Paint _highlightPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = const Color(0x33FFFFFF);

  bool _isInTray(PuzzlePiece piece) {
    if (piece.isPlaced) return false;
    final double pieceY = piece.currentPosition.dy;
    const double tolerance = 20.0;
    return pieceY >= (scatterArea.top - tolerance) &&
        pieceY <= (scatterArea.bottom + tolerance);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(boardRect, _boardOutlinePaint);

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
      final double effectiveTrayOffset =
          (_isInTray(piece) && !piece.isPlaced) ? trayOffset : 0.0;

      canvas.translate(
        piece.currentPosition.dx - effectiveTrayOffset,
        piece.currentPosition.dy + lift,
      );

      canvas.clipPath(piece.path);

      final destRect = Rect.fromLTWH(
        -piece.col * pieceWidth,
        -piece.row * pieceHeight,
        boardRect.width,
        boardRect.height,
      );
      canvas.drawImageRect(image, srcRect, destRect, _imagePaint);

      canvas.drawPath(piece.path, _borderPaint);

      if (!piece.isPlaced) {
        canvas.drawPath(piece.path, _highlightPaint);
      }

      canvas.restore();
    }
  }

  void _paintShadow(Canvas canvas, PuzzlePiece piece) {
    canvas.save();
    final double effectiveTrayOffset =
        (_isInTray(piece) && !piece.isPlaced) ? trayOffset : 0.0;

    canvas.translate(
      piece.currentPosition.dx - effectiveTrayOffset + 4,
      piece.currentPosition.dy + 8,
    );

    canvas.drawPath(piece.path, _shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.pieces != pieces ||
        oldDelegate.image != image ||
        oldDelegate.boardRect != boardRect ||
        oldDelegate.scatterArea != scatterArea ||
        oldDelegate.trayOffset != trayOffset;
  }
}
