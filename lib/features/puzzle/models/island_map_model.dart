import 'package:flutter/material.dart';


class IslandMapModel {


  final String islandId;


  // مكان الجزيرة على الخريطة
  final Offset position;


  // حجم الجزيرة
  final double size;



  const IslandMapModel({

    required this.islandId,

    required this.position,

    required this.size,

  });


}