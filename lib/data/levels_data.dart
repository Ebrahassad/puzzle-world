import '../models/puzzle_level_model.dart';


class LevelsData {


  static const List<PuzzleLevelModel> levels = [


    PuzzleLevelModel(

      id: 'easy',

      puzzleId: 'lion_1',

      gridSize: 3,

      piecesCount: 9,

      difficulty: 'سهل',

    ),



    PuzzleLevelModel(

      id: 'medium',

      puzzleId: 'lion_1',

      gridSize: 4,

      piecesCount: 16,

      difficulty: 'متوسط',

    ),



    PuzzleLevelModel(

      id: 'hard',

      puzzleId: 'lion_1',

      gridSize: 5,

      piecesCount: 25,

      difficulty: 'صعب',

    ),



  ];



  static List<PuzzleLevelModel> byPuzzle(

      String puzzleId

      ) {


    return levels

        .where(

          (level) =>

          level.puzzleId == puzzleId,

    )

        .toList();


  }


}
