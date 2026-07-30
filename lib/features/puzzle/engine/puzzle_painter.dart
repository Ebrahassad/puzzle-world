import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzlePainter extends CustomPainter {


  final PuzzlePiece piece;

  final ImageProvider image;

  final ui.Image? cachedImage;



  PuzzlePainter({

    required this.piece,

    required this.image,

    this.cachedImage,

  });





  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {


    final path = createPiecePath(size);



    //==================================================
    // ظل القطعة
    //==================================================

    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(0.25)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          4,

        ),

    );





    //==================================================
    // رسم صورة القطعة
    //==================================================

    if (cachedImage != null) {


      canvas.save();



      canvas.clipPath(path);





      // مهم جداً:
      // لا يوجد Scale هنا
      // sourceRect محسوب من PuzzleGenerator
      // حسب حجم الصورة الحقيقي


      final source = piece.sourceRect;





      final destination = Rect.fromLTWH(

        0,

        0,

        size.width,

        size.height,

      );





      canvas.drawImageRect(

        cachedImage!,

        source,

        destination,

        Paint()

          ..filterQuality = FilterQuality.high,

      );





      canvas.restore();


    }





    //==================================================
    // إطار القطعة
    //==================================================

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = piece.placed ? 3 : 1.5

        ..color = piece.placed

            ? Colors.greenAccent

            : Colors.white,

    );


  }

  Path createPiecePath(Size size) {


    final path = Path();

    final w = size.width;
    final h = size.height;

    // مساحة للـ tabs حتى لا تُقصّ من الأطراف
    final tab = (w < h ? w : h) * 0.18;

    final left = tab;
    final top = tab;
    final right = w - tab;
    final bottom = h - tab;

    final midX = w / 2;
    final midY = h / 2;



    path.moveTo(left, top);

    path.lineTo(
      midX - tab,
      top,
    );

    drawTop(
      path,
      piece.top,
      midX,
      top,
      tab,
    );

    path.lineTo(
      right,
      top,
    );

    path.lineTo(
      right,
      midY - tab,
    );

    drawRight(
      path,
      piece.right,
      right,
      midY,
      tab,
    );

    path.lineTo(
      right,
      bottom,
    );

    path.lineTo(
      midX + tab,
      bottom,
    );

    drawBottom(
      path,
      piece.bottom,
      midX,
      bottom,
      tab,
    );

    path.lineTo(
      left,
      bottom,
    );

    path.lineTo(
      left,
      midY + tab,
    );

    drawLeft(
      path,
      piece.left,
      left,
      midY,
      tab,
    );

    path.close();

    return path;
  }





  void drawTop(
    Path path,
    EdgeType type,
    double midX,
    double y,
    double tab,
  ) {
    if (type == EdgeType.tab) {
      path.cubicTo(
        midX - tab,
        y - tab,
        midX + tab,
        y - tab,
        midX + tab,
        y,
      );
    } else if (type == EdgeType.blank) {
      path.cubicTo(
        midX - tab,
        y + tab,
        midX + tab,
        y + tab,
        midX + tab,
        y,
      );
    }
  }





  void drawBottom(
    Path path,
    EdgeType type,
    double midX,
    double y,
    double tab,
  ) {
    if (type == EdgeType.tab) {
      path.cubicTo(
        midX + tab,
        y + tab,
        midX - tab,
        y + tab,
        midX - tab,
        y,
      );
    } else if (type == EdgeType.blank) {
      path.cubicTo(
        midX + tab,
        y - tab,
        midX - tab,
        y - tab,
        midX - tab,
        y,
      );
    }
  }





  void drawRight(
    Path path,
    EdgeType type,
    double x,
    double midY,
    double tab,
  ) {
    if (type == EdgeType.tab) {
      path.cubicTo(
        x + tab,
        midY - tab,
        x + tab,
        midY + tab,
        x,
        midY + tab,
      );
    } else if (type == EdgeType.blank) {
      path.cubicTo(
        x - tab,
        midY - tab,
        x - tab,
        midY + tab,
        x,
        midY + tab,
      );
    }
  }





  void drawLeft(
    Path path,
    EdgeType type,
    double x,
    double midY,
    double tab,
  ) {
    if (type == EdgeType.tab) {
      path.cubicTo(
        x - tab,
        midY + tab,
        x - tab,
        midY - tab,
        x,
        midY - tab,
      );
    } else if (type == EdgeType.blank) {
      path.cubicTo(
        x + tab,
        midY + tab,
        x + tab,
        midY - tab,
        x,
        midY - tab,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant PuzzlePainter oldDelegate,
  ) {
    return oldDelegate.piece != piece ||
        oldDelegate.cachedImage != cachedImage;
  }
}