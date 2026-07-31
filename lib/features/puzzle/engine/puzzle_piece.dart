import 'package:flutter/material.dart';

/// نوع شكل حافة قطعة البازل
enum EdgeType {
  flat,
  tab,
  blank,
}

/// اتجاه الحافة
enum EdgeSide {
  top,
  right,
  bottom,
  left,
}


/// تعريف حافة واحدة
class PuzzleEdge {

  final EdgeType type;

  final EdgeSide side;


  const PuzzleEdge({
    required this.type,
    required this.side,
  });


  bool get isFlat =>
      type == EdgeType.flat;


  bool get isTab =>
      type == EdgeType.tab;


  bool get isBlank =>
      type == EdgeType.blank;

}


/// نموذج قطعة البازل
class PuzzlePiece {


  final String id;


  /// مكان القطعة في الشبكة
  final int row;

  final int column;


  /// رقمها الصحيح
  final int correctIndex;


  /// الجزء الذي تأخذه من الصورة الأصلية
  final Rect sourceRect;


  /// الحواف الأربعة

  final PuzzleEdge top;

  final PuzzleEdge right;

  final PuzzleEdge bottom;

  final PuzzleEdge left;



  /// مكانها الصحيح في اللوحة

  final Offset targetPosition;



  /// حجم القطعة

  final Size size;



  /// مقدار النتوء

  final double tabSize;



  /// الموقع الحالي

  Offset position;



  /// أثناء السحب

  Offset dragOffset;



  /// هل يتم سحبها

  bool isDragging;



  /// هل ثبتت في مكانها

  bool isLocked;



  /// ترتيب الرسم فوق القطع

  int zIndex;



  PuzzlePiece({

    required this.id,

    required this.row,

    required this.column,

    required this.correctIndex,

    required this.sourceRect,

    required this.top,

    required this.right,

    required this.bottom,

    required this.left,

    required this.targetPosition,

    required this.size,

    required this.tabSize,

    required this.position,


    this.dragOffset = Offset.zero,

    this.isDragging = false,

    this.isLocked = false,

    this.zIndex = 0,

  });



  double get x =>
      position.dx;


  double get y =>
      position.dy;



  Rect get rect =>
      Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

  //======================================================
  // بدء السحب
  //======================================================

  void startDrag(Offset touchPosition) {

    if (isLocked) return;


    isDragging = true;


    dragOffset =
        touchPosition - position;


    zIndex = 999;

  }



  //======================================================
  // تحديث مكان القطعة أثناء السحب
  //======================================================

  void updateDrag(Offset touchPosition) {

    if (isLocked) return;


    position =
        touchPosition - dragOffset;

  }



  //======================================================
  // إنهاء السحب
  //======================================================

  void endDrag() {

    isDragging = false;

    zIndex = 0;

  }



  //======================================================
  // تحريك مباشر
  //======================================================

  void moveTo(Offset newPosition) {

    if (isLocked) return;


    position = newPosition;

  }



  //======================================================
  // حساب المسافة من مكانها الصحيح
  //======================================================

  double distanceToTarget() {

    return
        (position - targetPosition)
            .distance;

  }



  //======================================================
  // فحص الاقتراب
  //======================================================

  bool canSnap(
    double tolerance,
  ) {

    return distanceToTarget()
        <= tolerance;

  }



  //======================================================
  // تثبيت القطعة
  //======================================================

  void snap() {

    position =
        targetPosition;


    isLocked = true;


    isDragging = false;


    dragOffset =
        Offset.zero;

  }



  //======================================================
  // إلغاء التثبيت
  //======================================================

  void unlock() {

    isLocked = false;

  }



  //======================================================
  // إعادة القطعة لحالة البداية
  //======================================================

  void reset(
    Offset startPosition,
  ) {

    position =
        startPosition;


    dragOffset =
        Offset.zero;


    isDragging =
        false;


    isLocked =
        false;


    zIndex =
        0;

  }



  //======================================================
  // حفظ البيانات
  //======================================================

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "row": row,

      "column": column,

      "correctIndex":
          correctIndex,

      "x":
          position.dx,

      "y":
          position.dy,

      "locked":
          isLocked,

    };

  }

  //======================================================
  // استرجاع البيانات
  //======================================================

  factory PuzzlePiece.fromJson(
    Map<String, dynamic> json,
  ) {

    return PuzzlePiece(

      id:
          json["id"]?.toString() ?? "",


      row:
          json["row"] ?? 0,


      column:
          json["column"] ?? 0,


      correctIndex:
          json["correctIndex"] ?? 0,


      sourceRect:
          Rect.zero,


      top:
          const PuzzleEdge(
            type: EdgeType.flat,
            side: EdgeSide.top,
          ),


      right:
          const PuzzleEdge(
            type: EdgeType.flat,
            side: EdgeSide.right,
          ),


      bottom:
          const PuzzleEdge(
            type: EdgeType.flat,
            side: EdgeSide.bottom,
          ),


      left:
          const PuzzleEdge(
            type: EdgeType.flat,
            side: EdgeSide.left,
          ),


      targetPosition:
          Offset.zero,


      size:
          Size.zero,


      tabSize:
          0,


      position:
          Offset(
            (json["x"] ?? 0).toDouble(),
            (json["y"] ?? 0).toDouble(),
          ),


      isLocked:
          json["locked"] ?? false,

    );

  }



  //======================================================
  // نسخة جديدة من القطعة
  //======================================================

  PuzzlePiece copyWith({

    Offset? position,

    bool? isLocked,

    bool? isDragging,

    int? zIndex,

  }) {

    return PuzzlePiece(

      id:
          id,


      row:
          row,


      column:
          column,


      correctIndex:
          correctIndex,


      sourceRect:
          sourceRect,


      top:
          top,


      right:
          right,


      bottom:
          bottom,


      left:
          left,


      targetPosition:
          targetPosition,


      size:
          size,


      tabSize:
          tabSize,


      position:
          position ?? this.position,


      dragOffset:
          dragOffset,


      isDragging:
          isDragging ?? this.isDragging,


      isLocked:
          isLocked ?? this.isLocked,


      zIndex:
          zIndex ?? this.zIndex,

    );

  }



  //======================================================
  // مقارنة القطع
  //======================================================

  @override
  bool operator ==(
    Object other,
  ) {

    return identical(
      this,
      other,
    ) ||

    other is PuzzlePiece &&
        other.id == id;

  }



  @override
  int get hashCode =>
      id.hashCode;



  //======================================================
  // طباعة معلومات القطعة
  //======================================================

  @override
  String toString() {

    return
      "PuzzlePiece("
      "id:$id, "
      "row:$row, "
      "column:$column, "
      "position:$position, "
      "locked:$isLocked"
      ")";

  }

}