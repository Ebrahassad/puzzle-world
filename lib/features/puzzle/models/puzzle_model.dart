class PuzzleModel {


  // معرف الجزيرة
  final String id;


  // اسم الجزيرة
  final String title;


  // صورة الجزيرة
  final String image;


  // وصف الجزيرة
  final String description;


  // عدد المراحل داخل الجزيرة
  final int totalLevels;


  // هل الجزيرة مفتوحة
  final bool unlocked;


  // النجوم المطلوبة لفتح الجزيرة
  final int requiredStars;


  // ترتيب الجزيرة في الخريطة
  final int order;



  const PuzzleModel({

    required this.id,

    required this.title,

    this.image = "",

    this.description = "",

    this.totalLevels = 0,

    this.unlocked = true,

    this.requiredStars = 0,

    this.order = 0,

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

      "order": order,

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


      order:
      json["order"] ?? 0,

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

    int? order,

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


      order:
      order ?? this.order,

    );

  }





  //==================================================
  // مقارنة الجزر
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
 unlocked: $unlocked,
 order: $order
)

""";

  }


}