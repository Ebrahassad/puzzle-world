import 'package:flutter/material.dart';

import '../models/puzzle_world_model.dart';

const List<PuzzleWorldModel> puzzleWorlds = [

  PuzzleWorldModel(
    id: "animals",
    title: "عالم الحيوانات",
    description: "حيوانات أليفة ومفترسة",
    image: "assets/worlds/animals.png",
    icon: Icons.pets,
    color: Color(0xff6FCF97),
    totalPuzzles: 24,
  ),

  PuzzleWorldModel(
    id: "nature",
    title: "عالم الطبيعة",
    description: "جبال، أنهار، وغابات",
    image: "assets/worlds/nature.png",
    icon: Icons.landscape,
    color: Color(0xff27AE60),
    totalPuzzles: 20,
  ),

  PuzzleWorldModel(
    id: "cars",
    title: "عالم السيارات",
    description: "سيارات رياضية وكلاسيكية",
    image: "assets/worlds/cars.png",
    icon: Icons.directions_car,
    color: Color(0xff2F80ED),
    totalPuzzles: 18,
    unlocked: false,
    unlockType: WorldUnlockType.puzzles,
    unlockValue: 10,
  ),

  PuzzleWorldModel(
    id: "space",
    title: "عالم الفضاء",
    description: "كواكب ونجوم",
    image: "assets/worlds/space.png",
    icon: Icons.rocket_launch,
    color: Color(0xff9B51E0),
    totalPuzzles: 20,
    unlocked: false,
    unlockType: WorldUnlockType.ads,
    unlockValue: 15,
  ),

  PuzzleWorldModel(
    id: "cities",
    title: "عالم المدن",
    description: "أشهر مدن العالم",
    image: "assets/worlds/cities.png",
    icon: Icons.location_city,
    color: Color(0xffF2994A),
    totalPuzzles: 20,
    unlocked: false,
    unlockType: WorldUnlockType.coins,
    unlockValue: 2500,
  ),

  PuzzleWorldModel(
    id: "custom",
    title: "صوري الخاصة",
    description: "أنشئ بازل من صورك",
    image: "assets/worlds/custom.png",
    icon: Icons.photo_library,
    color: Color(0xffEB5757),
    totalPuzzles: 999,
    unlocked: false,
    unlockType: WorldUnlockType.ads,
    unlockValue: 50,
  ),
];