class PuzzleLevelModel {


  final String id;


  // حجم الشبكة 3 = 3x3 ، 4 = 4x4 ...
  final int gridSize;


  // عدد النجوم المطلوبة لفتح المرحلة (مستقبلاً)
  final int requiredStars;


  // هل المرحلة مفتوحة
  final bool unlocked;



  const PuzzleLevelModel({

    required this.id,

    required this.gridSize,

    this.requiredStars = 0,

    this.unlocked = false,

  });





  // تحويل إلى JSON

  Map<String, dynamic> toJson(){

    return {

      "id": id,

      "gridSize": gridSize,

      "requiredStars": requiredStars,

      "unlocked": unlocked,

    };

  }





  // قراءة من JSON

  factory PuzzleLevelModel.fromJson(

      Map<String, dynamic> json,

      ){

    return PuzzleLevelModel(

      id: json["id"] ?? "",


      gridSize:

      json["gridSize"] ?? 3,


      requiredStars:

      json["requiredStars"] ?? 0,


      unlocked:

      json["unlocked"] ?? false,

    );

  }





  // نسخة معدلة

  PuzzleLevelModel copyWith({

    String? id,

    int? gridSize,

    int? requiredStars,

    bool? unlocked,

  }){


    return PuzzleLevelModel(

      id: id ?? this.id,


      gridSize:

      gridSize ?? this.gridSize,


      requiredStars:

      requiredStars ?? this.requiredStars,


      unlocked:

      unlocked ?? this.unlocked,

    );


  }





  @override

  bool operator ==(Object other){


    if(identical(this, other)){

      return true;

    }


    return other is PuzzleLevelModel &&

        other.id == id;


  }





  @override

  int get hashCode => id.hashCode;



}