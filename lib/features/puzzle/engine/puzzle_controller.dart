import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import 'puzzle_generator.dart';
import 'puzzle_piece.dart';

/// Drives a jigsaw puzzle: owns every [PuzzlePiece], handles drag gestures,
/// and decides when a piece should snap into its solved position.
class PuzzleController extends ChangeNotifier {
  PuzzleController({this.snapTolerance = 28});

  final double snapTolerance;
  double trayOffset = 0.0;

  List<PuzzlePiece> _pieces = [];
  List<PuzzlePiece> get pieces => List.unmodifiable(_pieces);

  ui.Image? _image;
  ui.Image? get image => _image;

  ui.Rect _boardRect = ui.Rect.zero;
  ui.Rect get boardRect => _boardRect;

  ui.Rect _scatterArea = ui.Rect.zero;

  int rows = 0;
  int cols = 0;
  int? _seed;

  PuzzlePiece? _dragging;
  ui.Offset _dragOffset = ui.Offset.zero;
  int _zCounter = 0;

  ui.Offset? _lastPlacedPosition;
  ui.Offset? get lastPlacedPosition => _lastPlacedPosition;

  bool get isSolved => _pieces.isNotEmpty && _pieces.every((p) => p.isPlaced);

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
    _lastPlacedPosition = null;
    notifyListeners();
  }

  void restoreProgress(Map<String, dynamic> data) {
    final savedPieces = data["pieces"] as List<dynamic>?;
    if (savedPieces == null) return;

    for (final saved in savedPieces) {
      final id = saved["id"];
      final piece = _pieces.firstWhere(
        (p) => p.id.toString() == id.toString(),
        orElse: () => throw Exception("Piece not found"),
      );

      piece.currentPosition = ui.Offset(
        (saved["x"] ?? 0).toDouble(),
        (saved["y"] ?? 0).toDouble(),
      );

      piece.isPlaced = saved["placed"] ?? false;

      if (piece.isPlaced) {
        _lastPlacedPosition =
            piece.currentPosition + piece.path.getBounds().center;
      }
    }

    _zCounter = _pieces.length;
    notifyListeners();
  }

  void onPanStart(ui.Offset position) {
    final candidates = _pieces.where((p) => !p.isPlaced).toList()
      ..sort((a, b) => b.zOrder.compareTo(a.zOrder));

    for (final piece in candidates) {
      if (piece.containsPoint(position, trayOffset)) {
        _dragging = piece;
        _dragOffset = position -
            (piece.isPlaced
                ? piece.currentPosition
                : piece.currentPosition - ui.Offset(trayOffset, 0));
        piece.isDragging = true;
        piece.zOrder = ++_zCounter;
        notifyListeners();
        return;
      }
    }
  }

  void onPanUpdate(ui.Offset position) {
    final piece = _dragging;
    if (piece == null) return;

    final visual = position - _dragOffset;
    piece.currentPosition = visual +
        (piece.isPlaced ? ui.Offset.zero : ui.Offset(trayOffset, 0));

    notifyListeners();
  }

  void onPanEnd() {
    final piece = _dragging;
    if (piece == null) return;

    piece.isDragging = false;

    final bool nearCorrectPosition =
        piece.distanceToCorrect <= snapTolerance;

    final ui.Offset pieceCenter =
        piece.currentPosition + piece.path.getBounds().center;

    final bool insideBoard = _boardRect.contains(pieceCenter);

    if (nearCorrectPosition && insideBoard) {
      piece.currentPosition = piece.correctPosition;
      piece.isPlaced = true;

      _lastPlacedPosition =
          piece.currentPosition + piece.path.getBounds().center;
    }

    _dragging = null;
    notifyListeners();
  }

  void restart({ui.Rect? scatterArea, int? seed}) {
    if (_pieces.isEmpty) return;
    final area = scatterArea ?? _scatterArea;
    if (scatterArea != null) _scatterArea = scatterArea;

    resetSolvedState();
    PuzzleGenerator.rescatter(_pieces, area, seed: seed ?? _seed);
    notifyListeners();
  }

  void resetSolvedState() {
    for (final piece in _pieces) {
      piece.isPlaced = false;
      piece.isDragging = false;
    }
    _dragging = null;
    _lastPlacedPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pieces = [];
    _dragging = null;
    _image = null;
    _lastPlacedPosition = null;
    super.dispose();
  }
}
