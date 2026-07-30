import 'package:flutter/material.dart';

enum EdgeType {
  flat,
  tab,
  blank,
}

class PuzzlePiece {
  final String id;

  final int row;
  final int column;

  final int correctPosition;

  final Rect sourceRect;

  final EdgeType top;
  final EdgeType right;
  final EdgeType bottom;
  final EdgeType left;

  Offset position;

  bool placed;

  PuzzlePiece({
    required this.id,
    required this.row,
    required this.column,
    required this.correctPosition,
    required this.sourceRect,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.position,
    this.placed = false,
  });

  double get x => position.dx;

  double get y => position.dy;

  Offset get gridPosition =>
      Offset(column.toDouble(), row.toDouble());

  Offset correctOffset(double pieceSize) {
    return Offset(
      column * pieceSize,
      row * pieceSize,
    );
  }

  void moveTo(Offset value) {
    if (placed) return;

    position = value;
  }

  void lock(double pieceSize) {
    position = correctOffset(pieceSize);
    placed = true;
  }

  void unlock() {
    placed = false;
  }

  void reset() {
    position = Offset.zero;
    placed = false;
  }

  bool isCorrect(
    double pieceSize,
    double tolerance,
  ) {
    final target = correctOffset(pieceSize);

    return (position - target).distance <= tolerance;
  }
  PuzzlePiece copyWith({

    Offset? position,

    bool? placed,

  }) {

    return PuzzlePiece(

      id: id,

      row: row,

      column: column,

      correctPosition: correctPosition,

      sourceRect: sourceRect,

      top: top,

      right: right,

      bottom: bottom,

      left: left,

      position: position ?? this.position,

      placed: placed ?? this.placed,

    );

  }



  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "row": row,

      "column": column,

      "correctPosition": correctPosition,

      "x": position.dx,

      "y": position.dy,

      "placed": placed,

    };

  }



  factory PuzzlePiece.fromJson(

    Map<String, dynamic> json,

  ) {

    return PuzzlePiece(

      id: json["id"] ?? "",

      row: json["row"] ?? 0,

      column: json["column"] ?? 0,

      correctPosition:
          json["correctPosition"] ?? 0,

      sourceRect: Rect.zero,

      top: EdgeType.flat,

      right: EdgeType.flat,

      bottom: EdgeType.flat,

      left: EdgeType.flat,

      position: Offset(

        (json["x"] ?? 0).toDouble(),

        (json["y"] ?? 0).toDouble(),

      ),

      placed:
          json["placed"] ?? false,

    );

  }



  @override
  bool operator ==(
    Object other,
  ) {

    return identical(this, other) ||
        other is PuzzlePiece &&
        other.id == id;

  }



  @override
  int get hashCode =>
      id.hashCode;



  @override
  String toString() {

    return
    "PuzzlePiece("
    "id:$id,"
    "row:$row,"
    "column:$column,"
    "placed:$placed"
    ")";

  }

}