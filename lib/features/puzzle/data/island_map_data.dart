import 'package:flutter/material.dart';

import '../models/island_map_model.dart';



class IslandMapData {


  static const Map<String, IslandMapModel>
      positions = {


    // هنا نضع الجزر بعد ضبط الصورة


    "island_1":

    IslandMapModel(

      islandId: "island_1",

      position:
      Offset(100, 250),

      size:
      140,

    ),


  };


}