class PuzzleLevelModel {


  final String id;

  final int levelNumber;

  final String title;

  // صورة البازل
  final String image;

  // وصف المرحلة
  final String description;

  // مستوى الصعوبة
  final String difficulty;

  // حجم الشبكة
  final int gridSize;

  // النجوم المطلوبة للفتح
  final int requiredStars;

  // النجوم التي يحصل عليها عند الفوز
  final int rewardStars;

  final bool unlocked;

  final bool completed;

  final int earnedStars;



  const PuzzleLevelModel({

    required this.id,

    required this.gridSize,

    this.levelNumber = 1,

    this.title = "",

    this.image = "",

    this.description = "",

    this.difficulty = "easy",

    this.requiredStars = 0,

    this.rewardStars = 3,

    this.unlocked = false,

    this.completed = false,

    this.earnedStars = 0,

  });





  Map<String,dynamic> toJson(){

    return {

      "id": id,

      "levelNumber": levelNumber,

      "title": title,

      "image": image,

      "description": description,

      "difficulty": difficulty,

      "gridSize": gridSize,

      "requiredStars": requiredStars,

      "rewardStars": rewardStars,

      "unlocked": unlocked,

      "completed": completed,

      "earnedStars": earnedStars,

    };

  }





  factory PuzzleLevelModel.fromJson(
      Map<String,dynamic> json,
      ){

    return PuzzleLevelModel(

      id: json["id"] ?? "",

      levelNumber:
      json["levelNumber"] ?? 1,

      title:
      json["title"] ?? "",

      image:
      json["image"] ?? "",

      description:
      json["description"] ?? "",

      difficulty:
      json["difficulty"] ?? "easy",

      gridSize:
      json["gridSize"] ?? 3,

      requiredStars:
      json["requiredStars"] ?? 0,

      rewardStars:
      json["rewardStars"] ?? 3,

      unlocked:
      json["unlocked"] ?? false,

      completed:
      json["completed"] ?? false,

      earnedStars:
      json["earnedStars"] ?? 0,

    );

  }






  PuzzleLevelModel copyWith({

    String? id,

    int? levelNumber,

    String? title,

    String? image,

    String? description,

    String? difficulty,

    int? gridSize,

    int? requiredStars,

    int? rewardStars,

    bool? unlocked,

    bool? completed,

    int? earnedStars,

  }){


    return PuzzleLevelModel(

      id: id ?? this.id,

      levelNumber:
      levelNumber ?? this.levelNumber,

      title:
      title ?? this.title,

      image:
      image ?? this.image,

      description:
      description ?? this.description,

      difficulty:
      difficulty ?? this.difficulty,

      gridSize:
      gridSize ?? this.gridSize,

      requiredStars:
      requiredStars ?? this.requiredStars,

      rewardStars:
      rewardStars ?? this.rewardStars,

      unlocked:
      unlocked ?? this.unlocked,

      completed:
      completed ?? this.completed,

      earnedStars:
      earnedStars ?? this.earnedStars,

    );

  }





  @override
  bool operator ==(Object other){

    return identical(this, other) ||
        other is PuzzleLevelModel &&
        other.id == id;

  }



  @override
  int get hashCode => id.hashCode;




  @override
  String toString(){

    return """

PuzzleLevelModel(

 id: $id,

 level: $levelNumber,

 image: $image,

 grid: ${gridSize}x$gridSize,

 difficulty: $difficulty,

 stars: $earnedStars,

 unlocked: $unlocked,

 completed: $completed

)

""";

  }

}