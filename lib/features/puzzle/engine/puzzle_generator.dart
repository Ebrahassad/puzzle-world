import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'puzzle_piece.dart';

/// Builds a complete, ready-to-play jigsaw puzzle.
///
/// [PuzzleGenerator] decides which side of every piece has a tab, a blank,
/// or a flat border edge, constructs the cubic-Bézier [Path] for every
/// piece, and scatters them into a starting layout. It has no Flutter
/// widget dependencies — only `dart:ui` (for [Path]/[Offset]/[Rect]) and
/// `dart:math` (for randomisation) — so the whole geometry pipeline can be
/// unit tested without pumping a widget tree.
class PuzzleGenerator {
  PuzzleGenerator._();

  /// Generates every piece for a `rows x cols` puzzle of [image].
  ///
  /// * [boardRect] is where, in canvas coordinates, the *assembled* image
  ///   should live. Its size defines each cell's size
  ///   (`boardRect.width / cols` by `boardRect.height / rows`), so pick a
  ///   [boardRect] whose aspect ratio matches the image to avoid distortion.
  /// * [scatterArea] is the region pieces are randomly placed into before
  ///   the player starts solving — typically the full screen.
  /// * [seed] makes the generated tab/blank pattern *and* the scatter
  ///   layout reproducible; omit it for a different puzzle every time.
  /// * [knobFactor] controls how big tabs are relative to piece size —
  ///   0.18–0.32 looks natural; default 0.24.
  ///
  /// Works for any grid size (3x3, 4x4, 5x5, 6x6, ...) — rows/cols just
  /// change the loop bounds below, nothing is hard-coded to a specific size.
  static List<PuzzlePiece> generate({
    required Image image,
    required int rows,
    required int cols,
    required Rect boardRect,
    required Rect scatterArea,
    int? seed,
    double knobFactor = 0.24,
  }) {
    assert(rows > 0 && cols > 0);
    final random = Random(seed);
    final pieceW = boardRect.width / cols;
    final pieceH = boardRect.height / rows;
    final knob = min(pieceW, pieceH) * knobFactor;

    // --- Step 1: decide the interlocking pattern ---------------------------
    // horizontal[r][c] is the edge shared between piece (r,c) and (r+1,c).
    // vertical[r][c]   is the edge shared between piece (r,c) and (r,c+1).
    // +1 means the piece with the smaller row/col owns the tab that pokes
    // into the other piece; -1 means the reverse. Every internal edge is
    // decided exactly once and then read by *both* neighbouring pieces
    // (with an inverted sign for the second one), which is what guarantees
    // a tab and its matching blank are always geometrically identical.
    final horizontal = List.generate(
      rows - 1,
      (_) => List.generate(cols, (_) => random.nextBool() ? 1 : -1),
    );
    final vertical = List.generate(
      rows,
      (_) => List.generate(cols - 1, (_) => random.nextBool() ? 1 : -1),
    );

    // --- Step 2: build one Path per piece -----------------------------------
    final pieces = <PuzzlePiece>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final topSign = r == 0 ? 0 : -horizontal[r - 1][c];
        final bottomSign = r == rows - 1 ? 0 : horizontal[r][c];
        final leftSign = c == 0 ? 0 : -vertical[r][c - 1];
        final rightSign = c == cols - 1 ? 0 : vertical[r][c];

        final path = _buildPiecePath(
          width: pieceW,
          height: pieceH,
          knob: knob,
          topSign: topSign,
          rightSign: rightSign,
          bottomSign: bottomSign,
          leftSign: leftSign,
          random: random,
        );

        final localBounds = Rect.fromLTWH(
          -knob * 1.4,
          -knob * 1.4,
          pieceW + knob * 2.8,
          pieceH + knob * 2.8,
        );

        final correctPosition = Offset(
          boardRect.left + c * pieceW,
          boardRect.top + r * pieceH,
        );

        pieces.add(PuzzlePiece(
          id: r * cols + c,
          row: r,
          col: c,
          path: path,
          localBounds: localBounds,
          correctPosition: correctPosition,
          initialPosition: correctPosition, // overwritten by _scatter below
          top: _shapeFor(topSign),
          right: _shapeFor(rightSign),
          bottom: _shapeFor(bottomSign),
          left: _shapeFor(leftSign),
        ));
      }
    }

    _scatter(pieces, scatterArea, random);
    return pieces;
  }

  static EdgeShape _shapeFor(int sign) {
    if (sign == 0) return EdgeShape.flat;
    return sign > 0 ? EdgeShape.tab : EdgeShape.blank;
  }

  /// Randomly repositions every piece inside [area], keeping each piece's
  /// nominal cell fully on-screen. Exposed publicly so a host app can
  /// re-shuffle an already-generated puzzle (e.g. a "restart" button)
  /// without recomputing the tab/blank pattern.
  static void rescatter(List<PuzzlePiece> pieces, Rect area, {int? seed}) {
    _scatter(pieces, area, Random(seed));
  }

  static void _scatter(List<PuzzlePiece> pieces, Rect area, Random random) {
    for (final piece in pieces) {
      final w = piece.localBounds.width;
      final h = piece.localBounds.height;
      final maxX = max(area.left, area.right - w);
      final maxY = max(area.top, area.bottom - h);
      final dx = area.left + random.nextDouble() * (maxX - area.left);
      final dy = area.top + random.nextDouble() * (maxY - area.top);
      piece.currentPosition = Offset(dx, dy);
    }
  }

  /// Builds the closed outline of a single piece by walking its four sides
  /// clockwise starting at the top-left corner: top -> right -> bottom ->
  /// left -> close. Every side is either a straight line (flat/border side)
  /// or a "mushroom" tab/blank produced by [_addSide]. Because neighbouring
  /// pieces are generated from the same shared sign (see [generate]), the
  /// two curves are geometrically identical — just bulging in opposite
  /// directions — so every pair of neighbours fits together exactly, with
  /// no gaps and no triangular/diagonal artefacts, since everything is
  /// drawn with `lineTo`/`cubicTo` only.
  static Path _buildPiecePath({
    required double width,
    required double height,
    required double knob,
    required int topSign,
    required int rightSign,
    required int bottomSign,
    required int leftSign,
    required Random random,
  }) {
    final path = Path()..moveTo(0, 0);

    _addSide(path, const Offset(0, 0), Offset(width, 0),
        sign: topSign, knob: knob, random: random);
    _addSide(path, Offset(width, 0), Offset(width, height),
        sign: rightSign, knob: knob, random: random);
    _addSide(path, Offset(width, height), Offset(0, height),
        sign: bottomSign, knob: knob, random: random);
    _addSide(path, Offset(0, height), const Offset(0, 0),
        sign: leftSign, knob: knob, random: random);

    path.close();
    return path;
  }

  /// Draws one side of a piece from [start] to [end] and appends it to
  /// [path].
  ///
  /// [sign] is `0` for a flat border edge, `+1` for a tab (bulges to the
  /// outward side of the piece — clockwise winding means that's a 90°
  /// clockwise rotation of the travel direction) or `-1` for a blank
  /// (bulges inward, the mirror image).
  ///
  /// The curve is built from three cubic Béziers so the tab reads as a
  /// classic interlocking "mushroom": a straight neck, then a head that is
  /// *wider* than the neck's base (a small overhang), which is exactly what
  /// makes two puzzle pieces physically interlock rather than just touch.
  static void _addSide(
    Path path,
    Offset start,
    Offset end, {
    required int sign,
    required double knob,
    required Random random,
  }) {
    if (sign == 0) {
      path.lineTo(end.dx, end.dy);
      return;
    }

    final length = (end - start).distance;
    final dir = (end - start) / length; // unit vector along the edge
    // 90° clockwise rotation of `dir` — points to the outside of a
    // clockwise-wound piece, i.e. into the neighbouring cell.
    final normal = Offset(dir.dy, -dir.dx);

    final amp =
        knob * 0.95 * sign;

    final headHalf =
        length * 0.14;

    final neckL = length * 0.40; // where the straight run ends
    final neckR = length * 0.60; // where the straight run resumes
    final headL = length * 0.5 - headHalf; // left edge of the round head
    final headR = length * 0.5 + headHalf; // right edge of the round head

    Offset at(double along, double perp) => start + dir * along + normal * perp;

    path.lineTo(at(neckL, 0).dx, at(neckL, 0).dy);

    // Rising shoulder: neck baseline -> left corner of the head.
    var c1 = at(neckL + (headL - neckL) * 0.5, 0);
    var c2 = at(headL, amp * 0.7);
    var p = at(headL, amp);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    // Rounded head: left corner -> right corner (slight overshoot past
    // `amp` on the control points gives the head a domed top).
    c1 = at(headL + headHalf * 0.5, amp * 1.1);
    c2 = at(headR - headHalf * 0.5, amp * 1.1);
    p = at(headR, amp);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    // Falling shoulder: right corner of the head -> neck baseline.
    c1 = at(headR, amp * 0.7);
    c2 = at(headR - (headR - neckR) * 0.5, 0);
    p = at(neckR, 0);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    path.lineTo(end.dx, end.dy);
  }

  /// Decodes raw image bytes (e.g. from `rootBundle.load`, a file, or a
  /// network response) into a [Image] that [PuzzlePainter] can draw with
  /// `drawImageRect`. Pure `dart:ui` — no external packages.
  static Future<Image> decodeImage(Uint8List bytes) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
