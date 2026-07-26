class PuzzleLevelModel {


  // معرف المستوى
  final String id;


  // رقم المستوى
  final int levelNumber;


  // اسم المستوى
  final String title;


  // حجم شبكة البازل
  final int gridSize;


  // النجوم المطلوبة لفتح المستوى
  final int requiredStars;


  // هل المستوى مفتوح
  final bool unlocked;



  const PuzzleLevelModel({

    required this.id,

    required this.levelNumber,

    required this.title,

    required this.gridSize,

    required this.requiredStars,

    this.unlocked = false,

  });



  // نسخة معدلة

  PuzzleLevelModel copyWith({

    String? id,

    int? levelNumber,

    String? title,

    int? gridSize,

    int? requiredStars,

    bool? unlocked,

  }) {

    return PuzzleLevelModel(

      id: id ?? this.id,

      levelNumber: levelNumber ?? this.levelNumber,

      title: title ?? this.title,

      gridSize: gridSize ?? this.gridSize,

      requiredStars: requiredStars ?? this.requiredStars,

      unlocked: unlocked ?? this.unlocked,

    );

  }



  // تحويل إلى JSON

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "levelNumber": levelNumber,

      "title": title,

      "gridSize": gridSize,

      "requiredStars": requiredStars,

      "unlocked": unlocked,

    };

  }



  // قراءة من JSON

  factory PuzzleLevelModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return PuzzleLevelModel(

      id: json["id"] ?? "",

      levelNumber: json["levelNumber"] ?? 0,

      title: json["title"] ?? "",

      gridSize: json["gridSize"] ?? 3,

      requiredStars: json["requiredStars"] ?? 0,

      unlocked: json["unlocked"] ?? false,

    );

  }



  @override
  bool operator ==(Object other) {

    if (identical(this, other)) {

      return true;

    }

    return other is PuzzleLevelModel &&
        other.id == id;

  }



  @override
  int get hashCode => id.hashCode;



  @override
  String toString() {

    return """
PuzzleLevelModel(
 id: $id,
 level: $levelNumber,
 title: $title,
 grid: $gridSize,
 unlocked: $unlocked
)
""";

  }

}