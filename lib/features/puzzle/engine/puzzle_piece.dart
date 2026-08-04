‏import 'dart:ui';
‏
‏/// The shape of one side of a puzzle piece.
‏///
‏/// - [flat]  the side lies on the outer border of the image — a straight
‏///   line, because there is no neighbouring piece on that side.
‏/// - [tab]   the side bulges *outward* ("male" connector), growing into the
‏///   neighbouring piece's cell.
‏/// - [blank] the side is carved *inward* ("female" connector) so the
‏///   neighbour's tab has somewhere to nest.
‏enum EdgeShape { flat, tab, blank }
‏
‏/// A single interlocking jigsaw puzzle piece.
‏///
‏/// This class is intentionally a plain data + geometry holder with no
‏/// Flutter widget dependencies, which makes it trivial to unit test. It
‏/// knows:
‏///  * where it *should* sit when solved ([correctPosition]),
‏///  * where it *currently* sits on screen ([currentPosition]),
‏///  * the exact outline ([path]) used both to clip the source image when
‏///    painting and to do pixel-accurate hit testing while dragging.
‏class PuzzlePiece {
‏  PuzzlePiece({
‏    required this.id,
‏    required this.row,
‏    required this.col,
‏    required this.path,
‏    required this.localBounds,
‏    required this.correctPosition,
‏    required Offset initialPosition,
‏    this.top = EdgeShape.flat,
‏    this.right = EdgeShape.flat,
‏    this.bottom = EdgeShape.flat,
‏    this.left = EdgeShape.flat,
‏  }) : currentPosition = initialPosition;
‏
‏  /// Stable identifier, `row * cols + col`.
‏  final int id;
‏
‏  /// Row/column of this piece inside the grid (0-based).
‏  final int row;
‏  final int col;
‏
‏  /// The piece outline in *local* coordinates, i.e. relative to the piece's
‏  /// own cell top-left corner (0,0). The path extends outside the nominal
‏  /// `pieceWidth x pieceHeight` rectangle wherever a [tab] bulges into a
‏  /// neighbouring cell — that overshoot is what makes the interlock work.
‏  final Path path;
‏
‏  /// A cheap bounding rectangle (local space) that fully contains [path].
‏  /// Used for shadow/layout math only — hit testing always uses the exact
‏  /// [path], never this box, so tapping a "notch" cut out by a neighbouring
‏  /// blank correctly misses the piece.
‏  final Rect localBounds;
‏
‏  /// Where this piece's local origin (0,0) must be, in board/canvas
‏  /// coordinates, for the puzzle to be solved.
‏  final Offset correctPosition;
‏
‏  /// Where this piece's local origin (0,0) currently is, in board/canvas
‏  /// coordinates. Mutated every frame while dragging.
‏  Offset currentPosition;
‏
‏  /// Shape of each of the four sides — informational, the real geometry
‏  /// already lives in [path]. Handy for debugging or alternate renderers.
‏  final EdgeShape top;
‏  final EdgeShape right;
‏  final EdgeShape bottom;
‏  final EdgeShape left;
‏
‏  /// True once the piece has snapped to [correctPosition] and been locked
‏  /// in place (locked pieces are no longer draggable — see
‏  /// [PuzzleController.onPanStart]).
‏  bool isPlaced = false;
‏
‏  /// True while the pointer is currently dragging this piece. Used by the
‏  /// painter to draw a drop shadow under it.
‏  bool isDragging = false;
‏
‏  /// Paint/hit-test order. Higher draws on top. Bumped every time the piece
‏  /// is picked up so the active piece always renders above its neighbours.
‏  int zOrder = 0;
‏
‏  /// Returns true if [globalPoint] (board/canvas coordinates) falls inside
‏  /// this piece's exact silhouette.
‏  bool containsPoint(Offset globalPoint) {
‏    final local = globalPoint - currentPosition;
‏    return path.contains(local);
‏  }
‏
‏  /// Distance between where the piece currently is and where it belongs.
‏  /// The controller snaps the piece home when this is small enough.
‏  double get distanceToCorrect => (currentPosition - correctPosition).distance;
‏
‏  @override
‏  String toString() => 'PuzzlePiece(#$id r$row c$col placed:$isPlaced)';
‏}
‏