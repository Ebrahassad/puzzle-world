class PuzzleModel {


  final String id;


  final String title;


  final String image;


  const PuzzleModel({

    required this.id,

    required this.title,

    this.image = "",

  });





  // تحويل إلى JSON للحفظ مستقبلاً

  Map<String, dynamic> toJson(){

    return {

      "id": id,

      "title": title,

      "image": image,

    };

  }





  // قراءة من JSON

  factory PuzzleModel.fromJson(

      Map<String, dynamic> json,

      ){

    return PuzzleModel(

      id: json["id"] ?? "",

      title: json["title"] ?? "",

      image: json["image"] ?? "",

    );

  }





  // نسخة معدلة من البيانات

  PuzzleModel copyWith({

    String? id,

    String? title,

    String? image,

  }){


    return PuzzleModel(

      id: id ?? this.id,

      title: title ?? this.title,

      image: image ?? this.image,

    );


  }





  @override

  bool operator ==(Object other){


    if(identical(this, other)){

      return true;

    }


    return other is PuzzleModel &&

        other.id == id;


  }





  @override

  int get hashCode => id.hashCode;



}