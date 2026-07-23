import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';

class PuzzleImageSplitService {
  const PuzzleImageSplitService._();

  //==================================================
  // إنشاء قطع البازل
  //==================================================
  static List<PuzzlePiece> splitImage({
    required int gridSize,
    required double imageSize,
  }) {
    final pieces = <PuzzlePiece>[];

    final pieceSize = imageSize / gridSize;

    int index = 0;

    final random = Random();

    for (int row = 0; row < gridSize; row++) {
      for (int column = 0; column < gridSize; column++) {
        EdgeType top;
        EdgeType left;

        if (row == 0) {
          top = EdgeType.flat;
        } else {
          final previous =
              pieces[(row - 1) * gridSize + column];
          top = previous.bottom == EdgeType.tab
              ? EdgeType.blank
              : previous.bottom == EdgeType.blank
                  ? EdgeType.tab
                  : EdgeType.flat;
        }

        if (column == 0) {
          left = EdgeType.flat;
        } else {
          final previous =
              pieces[row * gridSize + column - 1];
          left = previous.right == EdgeType.tab
              ? EdgeType.blank
              : previous.right == EdgeType.blank
                  ? EdgeType.tab
                  : EdgeType.flat;
        }

        final bottom = row == gridSize - 1
            ? EdgeType.flat
            : (random.nextBool()
                ? EdgeType.tab
                : EdgeType.blank);

        final right = column == gridSize - 1
            ? EdgeType.flat
            : (random.nextBool()
                ? EdgeType.tab
                : EdgeType.blank);

        pieces.add(
          PuzzlePiece(
            id: "piece_$index",
            row: row,
            column: column,
            correctPosition: index,
            sourceRect: Rect.fromLTWH(
              column * pieceSize,
              row * pieceSize,
              pieceSize,
              pieceSize,
            ),
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            position: Offset.zero,
          ),
        );

        index++;
      }
    }

    return pieces;
  }

  //==================================================
  // مستطيل القطعة
  //==================================================
  static Rect getPieceRect({
    required int row,
    required int column,
    required int gridSize,
    required double imageSize,
  }) {
    final size = imageSize / gridSize;

    return Rect.fromLTWH(
      column * size,
      row * size,
      size,
      size,
    );
  }

  //==================================================
  // حجم القطعة
  //==================================================
  static double getPieceSize({
    required double imageSize,
    required int gridSize,
  }) {
    return imageSize / gridSize;
  }

  //==================================================
  // خلط القطع
  //==================================================
  static List<PuzzlePiece> shufflePieces(
    List<PuzzlePiece> pieces,
  ) {
    pieces.shuffle();
    return pieces;
  }
}