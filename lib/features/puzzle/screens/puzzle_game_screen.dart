import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../widgets/puzzle_piece_widget.dart';

import '../managers/puzzle_hint_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';

import 'puzzle_win_screen.dart';



class PuzzleGameScreen extends StatefulWidget {


  final PuzzleModel puzzle;


  final PuzzleLevelModel level;



  const PuzzleGameScreen({

    super.key,

    required this.puzzle,

    required this.level,

  });



  @override
  State<PuzzleGameScreen> createState() =>
      _PuzzleGameScreenState();

}







class _PuzzleGameScreenState
    extends State<PuzzleGameScreen> {



  late List<PuzzlePiece> pieces;


  late PuzzleController controller;



  Timer? timer;



  int moves = 0;


  int seconds = 0;


  int hints = 0;



  bool loading = true;


  bool finishing = false;



  final double boardSize = 350;



  double get pieceSize =>

      boardSize / widget.level.gridSize;





  @override
  void initState(){

    super.initState();

    createGame();

  }







  void createGame(){


    pieces = PuzzleGenerator.generate(


      rows: widget.level.gridSize,


      columns: widget.level.gridSize,


      imageWidth: boardSize,


      imageHeight: boardSize,


    );



    controller = PuzzleController(

      pieces: pieces,

    );



    loadProgress();


  }