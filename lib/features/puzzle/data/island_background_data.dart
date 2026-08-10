class IslandBackgroundData {
  static const Map<String, String> backgrounds = {
    // جزيرة الحيوانات
    "animals":
        "assets/images/background/animals_background.png",

    // جزيرة السيارات
    "cars":
        "assets/images/background/cars_background.png",

    // جزيرة الطبيعة
    "nature":
        "assets/images/background/nature_background.png",

    // جزيرة المعالم العالمية
    "landmarks":
        "assets/images/background/landmarks_background.png",

    // جزيرة الفضاء
    "space":
        "assets/images/background/space_background.png",
  };

  static String getBackground(String islandId) {
    assert(
      backgrounds.containsKey(islandId),
      'Unknown island background: $islandId',
    );

    return backgrounds[islandId]!;
  }
}