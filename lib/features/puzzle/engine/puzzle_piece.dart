import 'dart:ui';

enum EdgeShape { flat, tab, blank }

class PuzzlePiece {
  PuzzlePiece({
    required this.id,
    required this.row,
    required this.col,
    required this.path,
    required this.localBounds,
    required this.correctPosition,
    required Offset initialPosition,
    this.top = EdgeShape.flat,
    this.right = EdgeShape.flat,
    this.bottom = EdgeShape.flat,
    this.left = EdgeShape.flat,
  }) : currentPosition = initialPosition;

  final int id;
  final int row;
  final int col;
  final Path path;
  final Rect localBounds;
  final Offset correctPosition;
  Offset currentPosition;

  final EdgeShape top;
  final EdgeShape right;
  final EdgeShape bottom;
  final EdgeShape left;

  bool isPlaced = false;
  bool isDragging = false;
  int zOrder = 0;

  bool containsPoint(Offset globalPoint, double trayOffset) {
    final adjustedPosition = isPlaced
        ? currentPosition
        : currentPosition - Offset(trayOffset, 0);

    final local = globalPoint - adjustedPosition;
    return path.contains(local);
  }

  double get distanceToCorrect => (currentPosition - correctPosition).distance;

  @override
  String toString() => 'PuzzlePiece(#$id r$row c$col placed:$isPlaced)';
}
