class IslandMapModel {
  final String islandId;

  /// قيمة من 0 إلى 1
  final double x;

  /// قيمة من 0 إلى 1
  final double y;

  /// نسبة من عرض الشاشة
  final double size;

  const IslandMapModel({
    required this.islandId,
    required this.x,
    required this.y,
    required this.size,
  });
}