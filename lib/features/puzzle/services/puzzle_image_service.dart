import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';

class PuzzleImageService {
  const PuzzleImageService._();

  static const String _placeholder =
      "assets/images/Puzzle/puzzle_placeholder.png";

  //==================================================
  // صورة عالم من الموديل
  //==================================================

  static ImageProvider getImage(
    PuzzleModel puzzle,
  ) {
    if (puzzle.image.isEmpty) {
      return const AssetImage(_placeholder);
    }

    return AssetImage(puzzle.image);
  }

  //==================================================
  // صورة من مسار مباشر
  //==================================================

  static ImageProvider getImageFromPath(
    String path,
  ) {
    if (path.isEmpty) {
      return const AssetImage(_placeholder);
    }

    return AssetImage(path);
  }

  //==================================================
  // التحقق من صحة المسار
  //==================================================

  static bool isValidImage(
    String path,
  ) {
    return path.trim().isNotEmpty;
  }

  //==================================================
  // صور العوالم
  //==================================================

  static String getWorldImagePath(
    String worldId,
  ) {
    switch (worldId) {
      case "animals":
        return "assets/images/Puzzle/animals.png";

      case "nature":
        return "assets/images/Puzzle/nature.png";

      case "vehicles":
        return "assets/images/Puzzle/vehicles.png";

      case "fruits":
        return "assets/images/Puzzle/fruits.png";

      default:
        return _placeholder;
    }
  }

  //==================================================
  // صورة عالم بواسطة الـ id
  //==================================================

  static ImageProvider getWorldImage(
    String worldId,
  ) {
    return AssetImage(
      getWorldImagePath(worldId),
    );
  }
}