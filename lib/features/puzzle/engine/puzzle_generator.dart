import 'dart:math';
import 'package:flutter/material.dart';

import 'puzzle_piece.dart';

class PuzzleGenerator {
  PuzzleGenerator._();

  static List<PuzzlePiece> generate({
    required int rows,
    required int columns,
    required double imageWidth,
    required double imageHeight,
    Random? random,
  }) {
    final rng = random ?? Random();

    final pieces = <PuzzlePiece>[];

    final pieceWidth = imageWidth / columns;
    final pieceHeight = imageHeight / rows;

    // حجم إضافي حول القطعة حتى يشمل النتوءات
    final overlapX = pieceWidth * 0.18;
    final overlapY = pieceHeight * 0.18;

    final horizontalEdges = _createHorizontalEdges(
      rows,
      columns,
      rng,
    );

    final verticalEdges = _createVerticalEdges(
      rows,
      columns,
      rng,
    );

    int index = 0;

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        double left = column * pieceWidth;
        double top = row * pieceHeight;

        double width = pieceWidth;
        double height = pieceHeight;

        if (column > 0) {
          left -= overlapX;
          width += overlapX;
        }

        if (column < columns - 1) {
          width += overlapX;
        }

        if (row > 0) {
          top -= overlapY;
          height += overlapY;
        }

        if (row < rows - 1) {
          height += overlapY;
        }

        final sourceRect = Rect.fromLTWH(
          left.clamp(0.0, imageWidth),
          top.clamp(0.0, imageHeight),
          width.clamp(0.0, imageWidth),
          height.clamp(0.0, imageHeight),
        );

        final piece = PuzzlePiece(
          id: "piece_$index",

          row: row,
          column: column,

          correctPosition: index,

          sourceRect: sourceRect,

          top: row == 0
              ? EdgeType.flat
              : _reverse(
                  verticalEdges[row - 1][column],
                ),

          bottom: row == rows - 1
              ? EdgeType.flat
              : verticalEdges[row][column],

          left: column == 0
              ? EdgeType.flat
              : _reverse(
                  horizontalEdges[row][column - 1],
                ),

          right: column == columns - 1
              ? EdgeType.flat
              : horizontalEdges[row][column],

          position: Offset.zero,
        );

        pieces.add(piece);

        index++;
      }
    }

    // خلط أماكن القطع
    pieces.shuffle(rng);

    return pieces;
  }

  //==================================================
  // إنشاء الحواف الأفقية
  //==================================================

  static List<List<EdgeType>> _createHorizontalEdges(
    int rows,
    int columns,
    Random random,
  ) {
    return List.generate(
      rows,
      (_) => List.generate(
        columns - 1,
        (_) => _randomEdge(random),
      ),
    );
  }

  //==================================================
  // إنشاء الحواف الرأسية
  //==================================================

  static List<List<EdgeType>> _createVerticalEdges(
    int rows,
    int columns,
    Random random,
  ) {
    return List.generate(
      rows - 1,
      (_) => List.generate(
        columns,
        (_) => _randomEdge(random),
      ),
    );
  }

  //==================================================
  // حافة عشوائية
  //==================================================

  static EdgeType _randomEdge(
    Random random,
  ) {
    return random.nextBool()
        ? EdgeType.tab
        : EdgeType.blank;
  }

  //==================================================
  // عكس الحافة
  //==================================================

  static EdgeType _reverse(
    EdgeType edge,
  ) {
    switch (edge) {
      case EdgeType.tab:
        return EdgeType.blank;

      case EdgeType.blank:
        return EdgeType.tab;

      case EdgeType.flat:
        return EdgeType.flat;
    }
  }
}