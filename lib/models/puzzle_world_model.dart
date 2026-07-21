import 'package:flutter/material.dart';

enum WorldUnlockType {
  free,
  coins,
  ads,
  puzzles,
}

class PuzzleWorldModel {
  final String id;

  final String title;

  final String description;

  final String image;

  final IconData icon;

  final Color color;

  final int totalPuzzles;

  final int completedPuzzles;

  final WorldUnlockType unlockType;

  final int unlockValue;

  final bool unlocked;

  const PuzzleWorldModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
    required this.totalPuzzles,
    this.completedPuzzles = 0,
    this.unlockType = WorldUnlockType.free,
    this.unlockValue = 0,
    this.unlocked = true,
  });

  double get progress {
    if (totalPuzzles == 0) return 0;
    return completedPuzzles / totalPuzzles;
  }

  bool get completed =>
      completedPuzzles >= totalPuzzles;
}