class PuzzleModel {

  final String id;
  final String title;
  final String image;
  final String category;
  final int pieces;
  final bool locked;


  const PuzzleModel({

    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.pieces,
    this.locked = false,

  });

}
