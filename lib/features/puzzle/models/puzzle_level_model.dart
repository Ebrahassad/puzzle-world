class PuzzleLevelModel {

  // معرف المرحلة
  final String id;


  // رقم المرحلة داخل العالم
  final int levelNumber;


  // اسم المرحلة
  final String title;


  // صورة المرحلة (مستقبلاً)
  final String image;


  // حجم شبكة البازل
  // 3 = 3x3
  // 4 = 4x4
  final int gridSize;


  // النجوم المطلوبة لفتح المرحلة
  final int requiredStars;


  // هل المرحلة مفتوحة
  final bool unlocked;


  // هل تم إنهاء المرحلة
  final bool completed;


  // عدد النجوم التي حصل عليها اللاعب
  final int earnedStars;



  const PuzzleLevelModel({

    required this.id,

    required this.gridSize,

    this.levelNumber = 1,

    this.title = "",

    this.image = "",

    this.requiredStars = 0,

    this.unlocked = false,

    this.completed = false,

    this.earnedStars = 0,

  });





  //==================================================
  // JSON
  //==================================================

  Map<String,dynamic> toJson(){

    return {


      "id": id,


      "levelNumber": levelNumber,


      "title": title,


      "image": image,


      "gridSize": gridSize,


      "requiredStars": requiredStars,


      "unlocked": unlocked,


      "completed": completed,


      "earnedStars": earnedStars,


    };

  }





  //==================================================
  // FROM JSON
  //==================================================

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


      gridSize:
      json["gridSize"] ?? 3,


      requiredStars:
      json["requiredStars"] ?? 0,


      unlocked:
      json["unlocked"] ?? false,


      completed:
      json["completed"] ?? false,


      earnedStars:
      json["earnedStars"] ?? 0,


    );

  }





  //==================================================
  // COPY
  //==================================================

  PuzzleLevelModel copyWith({

    String? id,

    int? levelNumber,

    String? title,

    String? image,

    int? gridSize,

    int? requiredStars,

    bool? unlocked,

    bool? completed,

    int? earnedStars,

  }){


    return PuzzleLevelModel(


      id:
      id ?? this.id,


      levelNumber:
      levelNumber ?? this.levelNumber,


      title:
      title ?? this.title,


      image:
      image ?? this.image,


      gridSize:
      gridSize ?? this.gridSize,


      requiredStars:
      requiredStars ?? this.requiredStars,


      unlocked:
      unlocked ?? this.unlocked,


      completed:
      completed ?? this.completed,


      earnedStars:
      earnedStars ?? this.earnedStars,


    );

  }





  //==================================================
  // مقارنة
  //==================================================

  @override
  bool operator ==(Object other){


    if(identical(this,other)){

      return true;

    }


    return other is PuzzleLevelModel &&

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
 grid: $gridSize,
 unlocked: $unlocked,
 completed: $completed
)

""";

  }


}