class PuzzlePieceModel {

  final int id;

  final int correctIndex;

  int currentIndex;


  PuzzlePieceModel({

    required this.id,

    required this.correctIndex,

    required this.currentIndex,

  });


  bool get isCorrect =>
      currentIndex == correctIndex;

}