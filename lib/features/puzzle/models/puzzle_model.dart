class PuzzleModel {

  final String id;

  // اسم الجزيرة / اللعبة
  final String title;

  // صورة الجزيرة
  final String image;

  // وصف اللعبة
  final String description;

  // عدد المراحل
  final int totalLevels;

  // النجوم المطلوبة للفتح
  final int requiredStars;

  // ترتيب الظهور
  final int order;


  const PuzzleModel({

    required this.id,

    required this.title,

    required this.image,

    required this.description,

    required this.totalLevels,

    required this.requiredStars,

    required this.order,

  });



  PuzzleModel copyWith({

    String? id,

    String? title,

    String? image,

    String? description,

    int? totalLevels,

    int? requiredStars,

    int? order,

  }) {

    return PuzzleModel(

      id: id ?? this.id,

      title: title ?? this.title,

      image: image ?? this.image,

      description: description ?? this.description,

      totalLevels: totalLevels ?? this.totalLevels,

      requiredStars: requiredStars ?? this.requiredStars,

      order: order ?? this.order,

    );

  }



  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "title": title,

      "image": image,

      "description": description,

      "totalLevels": totalLevels,

      "requiredStars": requiredStars,

      "order": order,

    };

  }



  factory PuzzleModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return PuzzleModel(

      id: json["id"] ?? "",

      title: json["title"] ?? "",

      image: json["image"] ?? "",

      description: json["description"] ?? "",

      totalLevels: json["totalLevels"] ?? 0,

      requiredStars: json["requiredStars"] ?? 0,

      order: json["order"] ?? 0,

    );

  }



  @override
  bool operator ==(Object other) {

    return identical(this, other) ||

        other is PuzzleModel &&

        other.id == id;

  }



  @override
  int get hashCode => id.hashCode;



  @override
  String toString() {

    return """

PuzzleModel(

 id: $id,

 title: $title,

 levels: $totalLevels,

 requiredStars: $requiredStars,

 order: $order

)

""";

  }

}