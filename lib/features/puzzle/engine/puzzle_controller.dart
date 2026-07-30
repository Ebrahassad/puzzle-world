import 'package:flutter/material.dart';

import 'puzzle_piece.dart';

class PuzzleController {
  final List<PuzzlePiece> pieces;

  /// إزاحة اللوحة من الأعلى
  final double boardOffsetY;

  /// إزاحة اللوحة من اليسار
  final double boardOffsetX;

  PuzzleController({
    required this.pieces,
    this.boardOffsetX = 0,
    this.boardOffsetY = 0,
  });

  /// تحريك القطعة أثناء السحب
  void movePiece(
    PuzzlePiece piece,
    Offset position,
  ) {
    if (piece.placed) return;

    piece.position = position;
  }

  /// التحقق هل القطعة قريبة من مكانها الصحيح
  bool checkPiecePosition(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    if (piece.placed) return true;

    final targetPosition = _targetPosition(piece, pieceSize);

    final pieceCenter = Offset(
      piece.position.dx + (pieceSize / 2),
      piece.position.dy + (pieceSize / 2),
    );

    final targetCenter = Offset(
      targetPosition.dx + (pieceSize / 2),
      targetPosition.dy + (pieceSize / 2),
    );

    final distance = (pieceCenter - targetCenter).distance;

    final tolerance = pieceSize * 0.30;

    if (distance <= tolerance) {
      lockPiece(piece, pieceSize);
      return true;
    }

    return false;
  }

  /// تثبيت القطعة في مكانها النهائي
  void lockPiece(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    piece.position = _targetPosition(piece, pieceSize);
    piece.placed = true;
  }

  /// مساعدة: مكان القطعة الصحيح على اللوحة
  Offset _targetPosition(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    return Offset(
      boardOffsetX + (piece.column * pieceSize),
      boardOffsetY + (piece.row * pieceSize),
    );
  }

  //=========================================================
  // تثبيت قطعة كمساعدة (Hint)
  //=========================================================

  bool applyHint(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    if (piece.placed) {
      return false;
    }

    lockPiece(
      piece,
      pieceSize,
    );

    return true;
  }

  //=========================================================
  // عدد القطع المكتملة
  //=========================================================

  int get completedPieces {

    return pieces
        .where(
          (piece) => piece.placed,
        )
        .length;
  }

  //=========================================================
  // عدد القطع المتبقية
  //=========================================================

  int get remainingPieces {

    return pieces.length - completedPieces;
  }

  //=========================================================
  // نسبة الإنجاز
  //=========================================================

  double get progress {

    if (pieces.isEmpty) {
      return 0;
    }

    return completedPieces / pieces.length;
  }

  //=========================================================
  // هل انتهى البازل؟
  //=========================================================

  bool get isCompleted {

    if (pieces.isEmpty) {
      return false;
    }

    return pieces.every(
      (piece) => piece.placed,
    );
  }

  //=========================================================
  // إعادة تعيين اللعبة
  //=========================================================

  void reset() {

    for (final piece in pieces) {
      piece.reset();
    }
  }

  //=========================================================
  // إنهاء جميع القطع
  //=========================================================

  void completeAll(
    double pieceSize,
  ) {

    for (final piece in pieces) {

      lockPiece(
        piece,
        pieceSize,
      );
    }
  }
}