import '../managers/game_manager.dart';


class GameCore {


  final GameManager gameManager;


  GameCore({

    required this.gameManager,

  });



  // العملات

  int get coins =>

      gameManager.state.coins;



  // الجواهر

  int get gems =>

      gameManager.state.gems;



  // التلميحات

  int get hints =>

      gameManager.state.hints;



  // الإعلانات

  int get adsWatched =>

      gameManager.state.adsWatched;



  // الألغاز المكتملة

  int get completedPuzzles =>

      gameManager.state.completedPuzzles;



  // العوالم المفتوحة

  int get unlockedWorlds =>

      gameManager.state.unlockedWorlds;



}
