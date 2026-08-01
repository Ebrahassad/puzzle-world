import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'puzzle_generator.dart';
import 'puzzle_piece.dart';

/// Drives a jigsaw puzzle: owns every [PuzzlePiece], handles drag gestures,
/// and decides when a piece should snap into its solved position.
///
/// Extends [ChangeNotifier] so a [PuzzlePainter] can be repainted directly
/// by passing this controller as `CustomPaint`'s `repaint` listenable —
/// every drag frame calls [notifyListeners], which repaints the canvas
/// without the host widget needing `setState` (see [JigsawPuzzleView]).
class PuzzleController extends ChangeNotifier {
  PuzzleController({this.snapTolerance = 28});

  /// Max distance (canvas pixels) between a piece's current position and
  /// its correct position for it to snap home on release.
  final double snapTolerance;

  List<PuzzlePiece> _pieces = [];

  /// All pieces, exposed read-only. [PuzzlePainter] reads this every frame.
  List<PuzzlePiece> get pieces => List.unmodifiable(_pieces);

  ui.Image? _image;

  /// The source image the puzzle was generated from.
  ui.Image? get image => _image;

  ui.Rect _boardRect = ui.Rect.zero;

  /// Where, in canvas coordinates, the assembled puzzle lives.
  ui.Rect get boardRect => _boardRect;

  ui.Rect _scatterArea = ui.Rect.zero;

  int rows = 0;
  int cols = 0;
  int? _seed;

  PuzzlePiece? _dragging;
  ui.Offset _dragOffset = ui.Offset.zero; // pointer position relative to the piece's origin
  int _zCounter = 0;

  /// True once every piece has snapped into its correct spot.
  bool get isSolved => _pieces.isNotEmpty && _pieces.every((p) => p.isPlaced);

  /// (Re)builds the puzzle for [image], split into [rows] x [cols] pieces,
  /// and scatters the pieces into starting positions.
  ///
  /// * [boardRect] — where the assembled picture should sit once solved.
  /// * [scatterArea] — the region pieces are shuffled into to start
  ///   (usually the whole visible canvas).
  ///
  /// Internally delegates all geometry work to [PuzzleGenerator.generate].
  void initialize({
    required ui.Image image,
    required int rows,
    required int cols,
    required ui.Rect boardRect,
    required ui.Rect scatterArea,
    int? seed,
  }) {
    _image = image;
    this.rows = rows;
    this.cols = cols;
    _boardRect = boardRect;
    _scatterArea = scatterArea;
    _seed = seed;

    _pieces = PuzzleGenerator.generate(
      image: image,
      rows: rows,
      cols: cols,
      boardRect: boardRect,
      scatterArea: scatterArea,
      seed: seed,
    );

    _zCounter = _pieces.length;
    _dragging = null;
    notifyListeners();
  }

  /// Call from a `GestureDetector.onPanStart`. Finds the top-most
  /// not-yet-placed piece under [position] using each piece's exact outline
  /// (not its bounding box), makes it the active dragged piece, and brings
  /// it to the front by giving it the highest [PuzzlePiece.zOrder].
  ///
  /// Already-placed pieces are ignored so a finished section of the puzzle
  /// can't be knocked loose by an accidental drag.
  void onPanStart(ui.Offset position) {
    // Search from the most recently touched/highest piece downward so an
    // overlapping stack is picked correctly.
    final candidates = _pieces.where((p) => !p.isPlaced).toList()
      ..sort((a, b) => b.zOrder.compareTo(a.zOrder));

    for (final piece in candidates) {
      if (piece.containsPoint(position)) {
        _dragging = piece;
        _dragOffset = position - piece.currentPosition;
        piece.isDragging = true;
        piece.zOrder = ++_zCounter; // bring to front
        notifyListeners();
        return;
      }
    }
  }

  /// Call from `GestureDetector.onPanUpdate` with the pointer's current
  /// position. Moves the active piece so it stays under the finger at the
  /// same offset it was originally grabbed at, giving a smooth drag.
  void onPanUpdate(ui.Offset position) {
    final piece = _dragging;
    if (piece == null) return;
    piece.currentPosition = position - _dragOffset;
    notifyListeners();
  }

void onPanEnd() {
  final piece = _dragging;

  if (piece == null) return;

  piece.isDragging = false;

  // المسافة بين القطعة ومكانها الصحيح
  final bool nearCorrectPosition =
      piece.distanceToCorrect <= snapTolerance;

  // مركز القطعة للتأكد أنها داخل لوحة الحل
  final Offset pieceCenter =
      piece.currentPosition + piece.path.getBounds().center;

  final bool insideBoard =
      _boardRect.contains(pieceCenter);

  // التثبيت يحدث فقط إذا:
  // 1- القطعة قريبة من مكانها الصحيح
  // 2- القطعة داخل البورد
  if (nearCorrectPosition && insideBoard) {
    piece.currentPosition = piece.correctPosition;
    piece.isPlaced = true;
  }

  // إذا كانت القطعة خاطئة:
  // تبقى في مكانها ولا ترجع للشريط
  _dragging = null;

  notifyListeners();
}

  /// Reshuffles all pieces into fresh random positions inside the last-used
  /// scatter area (or [scatterArea] if provided) and clears every placed
  /// flag, without regenerating the tab/blank cut pattern — i.e. "restart
  /// this puzzle" using the exact same pieces.
  void restart({ui.Rect? scatterArea, int? seed}) {
    if (_pieces.isEmpty) return;
    final area = scatterArea ?? _scatterArea;
    if (scatterArea != null) _scatterArea = scatterArea;

    resetSolvedState();
    PuzzleGenerator.rescatter(_pieces, area, seed: seed ?? _seed);
    notifyListeners();
  }

  /// Clears [PuzzlePiece.isPlaced]/[PuzzlePiece.isDragging] on every piece
  /// without moving anything, so [isSolved] becomes false again. Useful for
  /// "keep the current layout but let me rearrange it" flows; [restart]
  /// calls this internally before re-scattering.
  void resetSolvedState() {
    for (final piece in _pieces) {
      piece.isPlaced = false;
      piece.isDragging = false;
    }
    _dragging = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pieces = [];
    _dragging = null;
    _image = null;
    super.dispose();
  }
}