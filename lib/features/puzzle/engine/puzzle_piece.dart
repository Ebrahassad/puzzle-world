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

  /// true طالما القطعة ما زالت جزءًا من شريط القطع وتتحرك مع تمريره.
  /// تصبح false بشكل دائم بمجرد أن يسحبها المستخدم أول مرة (سواء انتهى بها
  /// المطاف مثبّتة في مكانها الصحيح أو حرة في أي مكان آخر).
  bool inTray = true;

  int zOrder = 0;

  /// [trayOffset] لا يُستخدم إلا إذا كانت القطعة لا تزال داخل الشريط
  /// (inTray == true). القطعة الحرة أو المسحوبة تُفحص بموضعها الحقيقي مباشرة.
  bool containsPoint(Offset globalPoint, double trayOffset) {
    final adjustedPosition = inTray
        ? currentPosition - Offset(trayOffset, 0)
        : currentPosition;

    final local = globalPoint - adjustedPosition;
    return path.contains(local);
  }

  double get distanceToCorrect => (currentPosition - correctPosition).distance;

  @override
  String toString() =>
      'PuzzlePiece(#$id r$row c$col placed:$isPlaced tray:$inTray)';
}