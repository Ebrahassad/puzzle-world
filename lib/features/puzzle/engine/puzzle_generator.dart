import 'dart:math';
import 'package:flutter/material.dart';

import 'puzzle_piece.dart';

/// =======================================================
/// Professional Puzzle Generator
/// Puzzle World
/// =======================================================
///
/// المسؤوليات:
/// - قص الصورة إلى أجزاء صحيحة.
/// - إنشاء حدود القطع.
/// - إنشاء بيانات القطع فقط.
///
/// ملاحظة:
/// لا يقوم هذا الملف بتحديد أماكن ظهور القطع.
/// شاشة اللعبة هي المسؤولة عن ذلك.
/// =======================================================

class PuzzleGenerator {
  PuzzleGenerator._();

  static List<PuzzlePiece> generate({
    required int rows,
    required int columns,
    required double imageWidth,
    required double imageHeight,
    Random? random,
  }) {
    assert(rows > 0);
    assert(columns > 0);
    assert(imageWidth > 0);
    assert(imageHeight > 0);

    final rng = random ?? Random();

    final List<PuzzlePiece> pieces = [];

    final double pieceWidth = imageWidth / columns;
    final double pieceHeight = imageHeight / rows;

    /// إنشاء الحدود مرة واحدة فقط
    final horizontalEdges = _generateHorizontalEdges(
      rows: rows,
      columns: columns,
      random: rng,
    );

    final verticalEdges = _generateVerticalEdges(
      rows: rows,
      columns: columns,
      random: rng,
    );

    int index = 0;

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        final Rect sourceRect = Rect.fromLTWH(
          column * pieceWidth,
          row * pieceHeight,
          pieceWidth,
          pieceHeight,
        );

        final EdgeType top = row == 0
            ? EdgeType.flat
            : _reverseEdge(
                verticalEdges[row - 1][column],
              );

        final EdgeType bottom = row == rows - 1
            ? EdgeType.flat
            : verticalEdges[row][column];

        final EdgeType left = column == 0
            ? EdgeType.flat
            : _reverseEdge(
                horizontalEdges[row][column - 1],
              );

        final EdgeType right = column == columns - 1
            ? EdgeType.flat
            : horizontalEdges[row][column];

        pieces.add(
          PuzzlePiece(
            id: 'piece_$index',

            row: row,
            column: column,

            correctPosition: index,

            sourceRect: sourceRect,

            top: top,
            bottom: bottom,
            left: left,
            right: right,

            /// سيتم تحديد مكان القطعة لاحقاً
            /// داخل PuzzleController
            position: Offset.zero,
          ),
        );

        index++;
      }
    }

    /// خلط ترتيب القطع فقط
    pieces.shuffle(rng);

    return pieces;
  }

  //=========================================================
  // إنشاء الحدود الأفقية
  //=========================================================

  static List<List<EdgeType>> _generateHorizontalEdges({

    required int rows,

    required int columns,

    required Random random,

  }) {

    return List.generate(

      rows,

      (_) => List.generate(

        columns - 1,

        (_) => _randomEdge(random),

      ),

    );

  }

  //=========================================================
  // إنشاء الحدود الرأسية
  //=========================================================

  static List<List<EdgeType>> _generateVerticalEdges({

    required int rows,

    required int columns,

    required Random random,

  }) {

    return List.generate(

      rows - 1,

      (_) => List.generate(

        columns,

        (_) => _randomEdge(random),

      ),

    );

  }

  //=========================================================
  // إنشاء حد عشوائي
  //=========================================================

  static EdgeType _randomEdge(

    Random random,

  ) {

    return random.nextBool()

        ? EdgeType.tab

        : EdgeType.blank;

  }

  //=========================================================
  // عكس الحد للقطعة المجاورة
  //=========================================================

  static EdgeType _reverseEdge(

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