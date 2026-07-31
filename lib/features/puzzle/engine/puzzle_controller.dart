import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzleController {
  final List<PuzzlePiece> pieces;

  final double boardOffsetX;
  final double boardOffsetY;

  String? activePieceId;

  PuzzleController({
    required this.pieces,
    this.boardOffsetX = 0,
    this.boardOffsetY = 0,
  });

  //==================================================
  // بداية السحب: القطعة تصبح فوق الجميع
  //==================================================

  void startDragging(PuzzlePiece piece) {
    if (piece.placed) return;

    activePieceId = piece.id;
    bringToFront(piece);
  }

  //==================================================
  // نهاية السحب
  //==================================================

  void endDragging(PuzzlePiece piece) {
    if (activePieceId == piece.id) {
      activePieceId = null;
    }
  }

  //==================================================
  // هل القطعة هي الحالية
  //==================================================

  bool isActive(PuzzlePiece piece) {
    return activePieceId == piece.id;
  }

  //==================================================
  // رفع القطعة فوق باقي القطع
  //==================================================

  void bringToFront(PuzzlePiece piece) {
    final index = pieces.indexWhere((p) => p.id == piece.id);

    if (index < 0) return;

    final movedPiece = pieces.removeAt(index);
    pieces.add(movedPiece);
  }

  //==================================================
  // تحريك القطعة أثناء السحب
  //==================================================

  void movePiece(
    PuzzlePiece piece,
    Offset position,
  ) {
    if (piece.placed) return;

    bringToFront(piece);
    piece.moveTo(position);
  }

  //==================================================
  // فحص هل القطعة قريبة من مكانها الصحيح
  //==================================================

  bool checkPiecePosition(
    PuzzlePiece piece,
    double pieceSize, {
    double snapFactor = 0.40,
  }) {
    if (piece.placed) {
      return true;
    }

    final target = _targetPosition(
      piece,
      pieceSize,
    );

    final distance = (piece.position - target).distance;

    final tolerance = pieceSize * snapFactor;

    if (distance <= tolerance) {
      lockPiece(
        piece,
        pieceSize,
      );

      return true;
    }

    return false;
  }

  //==================================================
  // تثبيت القطعة
  //==================================================

  void lockPiece(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    piece.lock(pieceSize);
  }

  //==================================================
  // حساب مكان القطعة الصحيح
  //==================================================

  Offset _targetPosition(
    PuzzlePiece piece,
    double pieceSize,
  ) {
    return Offset(
      boardOffsetX + (piece.column * pieceSize),
      boardOffsetY + (piece.row * pieceSize),
    );
  }

  //==================================================
  // تثبيت قطعة بواسطة التلميح
  //==================================================

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

  //==================================================
  // عدد القطع المكتملة
  //==================================================

  int get completedPieces {
    return pieces.where((piece) => piece.placed).length;
  }

  //==================================================
  // عدد القطع المتبقية
  //==================================================

  int get remainingPieces {
    return pieces.length - completedPieces;
  }

  //==================================================
  // نسبة الإنجاز
  //==================================================

  double get progress {
    if (pieces.isEmpty) {
      return 0;
    }

    return completedPieces / pieces.length;
  }

  //==================================================
  // هل اكتمل البازل
  //==================================================

  bool get isCompleted {
    if (pieces.isEmpty) {
      return false;
    }

    return pieces.every((piece) => piece.placed);
  }

  //==================================================
  // إعادة اللعبة
  //==================================================

  void reset() {
    activePieceId = null;

    for (final piece in pieces) {
      piece.reset();
    }
  }

  //==================================================
  // إنهاء البازل كامل
  //==================================================

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

  //==================================================
  // إلغاء تثبيت قطعة
  //==================================================

  void unlockPiece(
    PuzzlePiece piece,
  ) {
    piece.placed = false;
  }

  //==================================================
  // البحث عن قطعة بواسطة ID
  //==================================================

  PuzzlePiece? findPiece(
    String id,
  ) {
    for (final piece in pieces) {
      if (piece.id == id) {
        return piece;
      }
    }

    return null;
  }

//=========================================
// بداية السحب
//=========================================

void startDragging(
  PuzzlePiece piece,
) {
  if (piece.placed) return;

  pieces.remove(piece);
  pieces.add(piece);
}

//=========================================
// نهاية السحب
//=========================================

void endDragging(
  PuzzlePiece piece,
) {
  // محجوز للتطوير لاحقاً
}
}