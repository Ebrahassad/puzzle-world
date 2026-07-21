import 'package:flutter/material.dart';


enum EdgeType {

  flat,

  tab,

  blank,

}



class PuzzlePiece {


  final int id;


  final int correctPosition;


  final int row;


  final int column;


  final Rect sourceRect;



  final EdgeType top;

  final EdgeType bottom;

  final EdgeType left;

  final EdgeType right;



  Offset position;


  bool placed;



  PuzzlePiece({


    required this.id,


    required this.correctPosition,


    required this.row,


    required this.column,


    required this.sourceRect,


    required this.top,


    required this.bottom,


    required this.left,


    required this.right,


    this.position = Offset.zero,


    this.placed = false,


  });



}
