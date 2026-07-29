import 'package:flutter/material.dart';

import '../models/island_map_model.dart';

class IslandMapData {

  static const Map<String, IslandMapModel> positions = {

    //==========================================
    // SPACE
    //==========================================

    "island_1": IslandMapModel(

      islandId: "island_1",

      position: Offset(572, 205),

      size: 170,

    ),

    //==========================================
    // WORLD LANDMARKS
    //==========================================

    "island_2": IslandMapModel(

      islandId: "island_2",

      position: Offset(856, 629),

      size: 170,

    ),

    //==========================================
    // ANIMALS
    //==========================================

    "island_3": IslandMapModel(

      islandId: "island_3",

      position: Offset(356, 593),

      size: 170,

    ),

    //==========================================
    // NATURE
    //==========================================

    "island_4": IslandMapModel(

      islandId: "island_4",

      position: Offset(844, 1099),

      size: 170,

    ),

    //==========================================
    // CARS
    //==========================================

    "island_5": IslandMapModel(

      islandId: "island_5",

      position: Offset(376, 1099),

      size: 170,

    ),

  };

}