import '../../puzzle/models/puzzle_level_model.dart';


class PuzzleLevelData {


static PuzzleLevelModel firstLevel(){

return const PuzzleLevelModel(

id:"level_1",

puzzleId:"animals_1",

gridSize:3,

piecesCount:9,

difficulty:"easy",

unlocked:true,

);


}


}