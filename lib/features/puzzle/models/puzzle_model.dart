class PuzzleModel {
  // معرف العالم
  final String id;

  // اسم العالم
  final String title;

  // صورة العالم
  final String image;

  // وصف العالم (مستقبلاً)
  final String description;

  // عدد المراحل داخل العالم
  final int totalLevels;

  // هل العالم مفتوح
  final bool unlocked;

  // النجوم المطلوبة لفتح العالم
  final int requiredStars;


  const PuzzleModel({

    required this.id,

    required this.title,

    this.image = "",

    this.description = "",

    this.totalLevels = 0,

    this.unlocked = true,

    this.requiredStars = 0,

  });



  //==================================================
  // تحويل إلى JSON
  //==================================================

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "title": title,

      "image": image,

      "description": description,

      "totalLevels": totalLevels,

      "unlocked": unlocked,

      "requiredStars": requiredStars,

    };

  }





  //==================================================
  // قراءة من JSON
  //==================================================

  factory PuzzleModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return PuzzleModel(

      id: json["id"] ?? "",


      title: json["title"] ?? "",


      image: json["image"] ?? "",


      description:
      json["description"] ?? "",


      totalLevels:
      json["totalLevels"] ?? 0,


      unlocked:
      json["unlocked"] ?? true,


      requiredStars:
      json["requiredStars"] ?? 0,

    );

  }





  //==================================================
  // نسخة معدلة
  //==================================================

  PuzzleModel copyWith({

    String? id,

    String? title,

    String? image,

    String? description,

    int? totalLevels,

    bool? unlocked,

    int? requiredStars,

  }) {


    return PuzzleModel(

      id: id ?? this.id,

      title: title ?? this.title,

      image: image ?? this.image,

      description:
      description ?? this.description,

      totalLevels:
      totalLevels ?? this.totalLevels,

      unlocked:
      unlocked ?? this.unlocked,

      requiredStars:
      requiredStars ?? this.requiredStars,

    );

  }





  //==================================================
  // مقارنة العوالم
  //==================================================

  @override
  bool operator ==(Object other) {

    if (identical(this, other)) {

      return true;

    }


    return other is PuzzleModel &&
        other.id == id;

  }





  @override
  int get hashCode => id.hashCode;





  //==================================================
  // عرض نصي للتصحيح
  //==================================================

  @override
  String toString() {

    return """

PuzzleModel(
 id: $id,
 title: $title,
 levels: $totalLevels,
 unlocked: $unlocked
)

""";

  }

}