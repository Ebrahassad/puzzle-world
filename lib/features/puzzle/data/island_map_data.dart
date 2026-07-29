import 'package:flutter/material.dart';

import '../models/island_map_model.dart';

class IslandMapData {

  static const Map<String, IslandMapModel> positions = {

    //==========================================
    // ANIMALS
    //==========================================

    "animals": IslandMapModel(

      islandId: "animals",

      position: Offset(356, 593),

      size: 170,

    ),

    //==========================================
    // CARS
    //==========================================

    "cars": IslandMapModel(

      islandId: "cars",

      position: Offset(376, 1099),

      size: 170,

    ),

    //==========================================
    // NATURE
    //==========================================

    "nature": IslandMapModel(

      islandId: "nature",

      position: Offset(844, 1099),

      size: 170,

    ),

    //==========================================
    // LANDMARKS
    //==========================================

    "landmarks": IslandMapModel(

      islandId: "landmarks",

      position: Offset(856, 629),

      size: 170,

    ),

    //==========================================
    // SPACE
    //==========================================

    "space": IslandMapModel(

      islandId: "space",

      position: Offset(572, 205),

      size: 170,

    ),

  };

}