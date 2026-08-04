import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import 'puzzle_generator.dart';
import 'puzzle_piece.dart';
import 'tray_controller.dart';

enum _TrayDragMode { none, piece, tray }

/// Drives a jigsaw puzzle: owns every [PuzzlePiece], handles drag gestures,
/// and decides when a piece should snap into its solved position.
class PuzzleController extends ChangeNotifier {
  PuzzleController({this.snapTolerance = 28}) {
    trayController.addListener(_onTrayChanged);
  }

  final double snapTolerance;

  /// يدير التمرير الأفقي الحقيقي لشريط القطع.
  final TrayController trayController = TrayController();

  /// إزاحة الشريط الحالية (قراءة فقط) — مصدرها TrayController.
  double get trayOffset => trayController.offsetX;

  List<PuzzlePiece> _pieces = [];
  List<PuzzlePiece> get pieces => List.unmodifiable(_pieces);

  ui.Image? _image;
  ui.Image? get image => _image;

  ui.Rect _boardRect = ui.Rect.zero;
  ui.Rect get boardRect => _boardRect;

  ui.Rect _scatterArea = ui.Rect.zero;
  ui.Rect get scatterArea => _scatterArea;

  int rows = 0;
  int cols = 0;
  int? _seed;

  PuzzlePiece? _dragging;
  ui.Offset _dragOffset = ui.Offset.zero;
  int _zCounter = 0;
  _TrayDragMode _dragMode = _TrayDragMode.none;

  ui.Offset? _lastPlacedPosition;
  ui.Offset? get lastPlacedPosition => _lastPlacedPosition;

  bool get isSolved => _pieces.isNotEmpty && _pieces.every((p) => p.isPlaced);

  void _onTrayChanged() => notifyListeners();

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
    _dragMode = _TrayDragMode.none;
    _lastPlacedPosition = null;

    trayController.reset();
    _updateTrayBounds();

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

      // الموضع المحفوظ إحداثي مطلق وليس نسبيًا للشريط، لذلك يجب ألا يتأثر
      // بـ trayOffset بعد الاستعادة.
      piece.inTray = false;

      if (piece.isPlaced) {
        _lastPlacedPosition =
            piece.currentPosition + piece.path.getBounds().center;
      }
    }

    _zCounter = _pieces.length;
    _updateTrayBounds();
    notifyListeners();
  }

  void onPanStart(ui.Offset position) {
    final candidates = _pieces.where((p) => !p.isPlaced).toList()
      ..sort((a, b) => b.zOrder.compareTo(a.zOrder));

    for (final piece in candidates) {
      if (piece.containsPoint(position, trayOffset)) {
        _dragMode = _TrayDragMode.piece;
        _dragging = piece;

        if (piece.inTray) {
          // فصل نهائي عن الشريط: نحوّل الموضع من "نسبي للشريط" إلى "مطلق"
          // في اللحظة التي يُمسك فيها المستخدم بالقطعة.
          piece.currentPosition =
              piece.currentPosition - ui.Offset(trayOffset, 0);
          piece.inTray = false;
        }

        _dragOffset = position - piece.currentPosition;
        piece.isDragging = true;
        piece.zOrder = ++_zCounter;
        notifyListeners();
        return;
      }
    }

    // لم تُلمس أي قطعة — إذا كانت اللمسة داخل منطقة الشريط، نبدأ تمرير الشريط.
    if (_scatterArea.contains(position)) {
      _dragMode = _TrayDragMode.tray;
      trayController.startDrag(position.dx);
    }
  }

  void onPanUpdate(ui.Offset position) {
    switch (_dragMode) {
      case _TrayDragMode.piece:
        final piece = _dragging;
        if (piece == null) return;
        // قطعة حرة: تتبع الإصبع مباشرة، لا تتأثر بـ trayOffset إطلاقًا.
        piece.currentPosition = position - _dragOffset;
        notifyListeners();
        break;
      case _TrayDragMode.tray:
        trayController.updateDrag(position.dx);
        break;
      case _TrayDragMode.none:
        break;
    }
  }

  void onPanEnd() {
    if (_dragMode == _TrayDragMode.tray) {
      _dragMode = _TrayDragMode.none;
      return;
    }

    final piece = _dragging;
    _dragMode = _TrayDragMode.none;
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
    // إن لم تكن صحيحة، تبقى القطعة تمامًا في مكانها الحالي (inTray أصلًا
    // false، فلن تعود أبدًا تلقائيًا إلى الشريط).

    _dragging = null;
    notifyListeners();
  }

  void restart({ui.Rect? scatterArea, int? seed}) {
    if (_pieces.isEmpty) return;
    final area = scatterArea ?? _scatterArea;
    if (scatterArea != null) _scatterArea = scatterArea;

    resetSolvedState();
    PuzzleGenerator.rescatter(_pieces, area, seed: seed ?? _seed);

    trayController.reset();
    _updateTrayBounds();

    notifyListeners();
  }

  void resetSolvedState() {
    for (final piece in _pieces) {
      piece.isPlaced = false;
      piece.isDragging = false;
      piece.inTray = true;
    }
    _dragging = null;
    _dragMode = _TrayDragMode.none;
    _lastPlacedPosition = null;
    notifyListeners();
  }

  void _updateTrayBounds() {
    final contentWidth =
        PuzzleGenerator.measureContentWidth(_pieces, _scatterArea);
    trayController.setBounds(
      contentWidth: contentWidth,
      viewportWidth: _scatterArea.width,
    );
  }

  @override
  void dispose() {
    trayController.removeListener(_onTrayChanged);
    trayController.dispose();
    _pieces = [];
    _dragging = null;
    _dragMode = _TrayDragMode.none;
    _image = null;
    _lastPlacedPosition = null;
    super.dispose();
  }
}