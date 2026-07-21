class PuzzleLevelModel {

  final String id;
  final String puzzleId;
  final int gridSize;
  final int piecesCount;
  final String difficulty;
  final bool unlocked;


  const PuzzleLevelModel({

    required this.id,
    required this.puzzleId,
    required this.gridSize,
    required this.piecesCount,
    required this.difficulty,
    this.unlocked = true,

  });

}
