import 'dartui';

/// The shape of one side of a puzzle piece.
///
/// - [flat]  the side lies on the outer border of the image — a straight
///   line, because there is no neighbouring piece on that side.
/// - [tab]   the side bulges outward ("male" connector), growing into the
///   neighbouring piece's cell.
/// - [blank] the side is carved inward ("female" connector) so the
///   neighbour's tab has somewhere to nest.
enum EdgeShape { flat, tab, blank }

/// A single interlocking jigsaw puzzle piece.
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

  /// Stable identifier.
  final int id;

  /// Row position inside grid.
  final int row;

  /// Column position inside grid.
  final int col;

  /// Piece outline.
  final Path path;

  /// Bounds containing the path.
  final Rect localBounds;

  /// Correct solved position.
  final Offset correctPosition;

  /// Current position on canvas.
  Offset currentPosition;

  /// Edge shapes.
  final EdgeShape top;
  final EdgeShape right;
  final EdgeShape bottom;
  final EdgeShape left;

  /// Locked after snapping.
  bool isPlaced = false;

  /// Currently dragged.
  bool isDragging = false;

  /// Drawing order.
  int zOrder = 0;


  /// Hit testing.
  bool containsPoint(Offset globalPoint) {
    final local = globalPoint - currentPosition;
    return path.contains(local);
  }


  /// Distance from correct position.
  double get distanceToCorrect =>
      (currentPosition - correctPosition).distance;


  @override
  String toString() {
    return 'PuzzlePiece(#$id r$row c$col placed:$isPlaced)';
  }
}