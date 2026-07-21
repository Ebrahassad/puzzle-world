import 'package:flutter/material.dart';


class IslandModel {


  final String id;


  final String title;


  final String worldId;


  final Offset position;


  final IconData icon;


  final Color color;


  final bool unlocked;


  final int levels;



  const IslandModel({


    required this.id,


    required this.title,


    required this.worldId,


    required this.position,


    required this.icon,


    required this.color,


    required this.levels,


    this.unlocked = false,

  });

}
