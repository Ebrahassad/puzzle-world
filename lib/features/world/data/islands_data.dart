import 'package:flutter/material.dart';

import '../models/island_model.dart';



final List<IslandModel> islands = [



  IslandModel(

    id:"animals",

    title:"الحيوانات",

    worldId:"animals",

    position:Offset(.5,.15),

    icon:Icons.pets,

    color:Color(0xff6FCF97),

    levels:24,

    unlocked:true,

  ),





  IslandModel(

    id:"nature",

    title:"الطبيعة",

    worldId:"nature",

    position:Offset(.3,.35),

    icon:Icons.forest,

    color:Color(0xff27AE60),

    levels:20,

  ),





  IslandModel(

    id:"cars",

    title:"السيارات",

    worldId:"cars",

    position:Offset(.65,.55),

    icon:Icons.directions_car,

    color:Color(0xff2F80ED),

    levels:18,

  ),





  IslandModel(

    id:"space",

    title:"الفضاء",

    worldId:"space",

    position:Offset(.4,.75),

    icon:Icons.rocket_launch,

    color:Color(0xff9B51E0),

    levels:20,

  ),



];
