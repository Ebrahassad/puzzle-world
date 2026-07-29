import '../models/island_map_model.dart';

class IslandMapData {
  static const Map<String, IslandMapModel> positions = {

    //==========================================
    // ANIMALS
    //==========================================

    "animals": IslandMapModel(
      islandId: "animals",
      x: 0.28,
      y: 0.31,
      size: 0.15,
    ),

    //==========================================
    // CARS
    //==========================================

    "cars": IslandMapModel(
      islandId: "cars",
      x: 0.28,
      y: 0.58,
      size: 0.15,
    ),

    //==========================================
    // NATURE
    //==========================================

    "nature": IslandMapModel(
      islandId: "nature",
      x: 0.67,
      y: 0.58,
      size: 0.15,
    ),

    //==========================================
    // LANDMARKS
    //==========================================

    "landmarks": IslandMapModel(
      islandId: "landmarks",
      x: 0.67,
      y: 0.33,
      size: 0.15,
    ),

    //==========================================
    // SPACE
    //==========================================

    "space": IslandMapModel(
      islandId: "space",
      x: 0.47,
      y: 0.10,
      size: 0.15,
    ),
  };
}