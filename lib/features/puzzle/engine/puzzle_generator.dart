import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'puzzle_piece.dart';

class PuzzleGenerator {
  PuzzleGenerator._();

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

    final horizontal = List.generate(
      rows - 1,
      (_) => List.generate(cols, (_) => random.nextBool() ? 1 : -1),
    );
    final vertical = List.generate(
      rows,
      (_) => List.generate(cols - 1, (_) => random.nextBool() ? 1 : -1),
    );

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
          initialPosition: correctPosition,
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

  static void rescatter(List<PuzzlePiece> pieces, Rect area, {int? seed}) {
    _scatter(pieces, area, Random(seed));
  }

  /// يحسب العرض الحقيقي لمحتوى الشريط (كل القطع بعد توزيعها أفقيًا) بدءًا من
  /// الحافة اليسرى لـ [area]. يُستخدم لضبط حدود [TrayController] بحيث لا
  /// تُقصّ أي قطعة خارج نطاق التمرير المسموح.
  static double measureContentWidth(List<PuzzlePiece> pieces, Rect area) {
    if (pieces.isEmpty) return area.width;

    double maxRight = area.left;
    for (final piece in pieces) {
      final right = piece.currentPosition.dx + piece.localBounds.width;
      if (right > maxRight) maxRight = right;
    }

    return (maxRight - area.left) + 10.0;
  }

  static void _scatter(List<PuzzlePiece> pieces, Rect area, Random random) {
    final shuffledPieces = List<PuzzlePiece>.from(pieces)..shuffle(random);

    final spacing = 8.0; // تقليل المسافة بين القطع لتظهر متناسقة
    double x = area.left + 10.0;
    final centerY = area.center.dy;

    for (final piece in shuffledPieces) {
      final h = piece.localBounds.height;

      piece.currentPosition = Offset(
        x,
        centerY - h / 2,
      );

      x += (piece.localBounds.width * 0.65) + spacing;
    }
  }

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
    final dir = (end - start) / length;
    final normal = Offset(dir.dy, -dir.dx);

    final amp = knob * (0.85 + random.nextDouble() * 0.3) * sign;
    final headHalf = length * (0.13 + random.nextDouble() * 0.03);

    final neckL = length * 0.40;
    final neckR = length * 0.60;
    final headL = length * 0.5 - headHalf;
    final headR = length * 0.5 + headHalf;

    Offset at(double along, double perp) => start + dir * along + normal * perp;

    path.lineTo(at(neckL, 0).dx, at(neckL, 0).dy);

    var c1 = at(neckL + (headL - neckL) * 0.5, 0);
    var c2 = at(headL, amp * 0.7);
    var p = at(headL, amp);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    c1 = at(headL + headHalf * 0.5, amp * 1.1);
    c2 = at(headR - headHalf * 0.5, amp * 1.1);
    p = at(headR, amp);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    c1 = at(headR, amp * 0.7);
    c2 = at(headR - (headR - neckR) * 0.5, 0);
    p = at(neckR, 0);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);

    path.lineTo(end.dx, end.dy);
  }

  static Future<Image> decodeImage(Uint8List bytes) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}