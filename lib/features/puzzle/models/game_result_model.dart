class GameResultModel {

  // عدد النجوم
  final int stars;


  // عدد الحركات
  final int moves;


  // وقت إنهاء المرحلة
  final Duration time;


  const GameResultModel({

    required this.stars,

    required this.moves,

    required this.time,

  });





  //==================================================
  // الوقت بالثواني
  //==================================================

  int get seconds => time.inSeconds;





  //==================================================
  // تقييم النتيجة
  //==================================================

  String get rating {

    if(stars >= 3){

      return "ممتاز";

    }

    if(stars == 2){

      return "جيد جداً";

    }

    if(stars == 1){

      return "جيد";

    }

    return "حاول مرة أخرى";

  }





  //==================================================
  // هل النتيجة كاملة
  //==================================================

  bool get isPerfect => stars == 3;





  //==================================================
  // JSON
  //==================================================

  Map<String,dynamic> toJson(){

    return {

      "stars": stars,

      "moves": moves,

      "seconds": seconds,

    };

  }





  //==================================================
  // FROM JSON
  //==================================================

  factory GameResultModel.fromJson(

      Map<String,dynamic> json,

      ){

    return GameResultModel(

      stars:
      json["stars"] ?? 0,


      moves:
      json["moves"] ?? 0,


      time:
      Duration(

        seconds:
        json["seconds"] ?? 0,

      ),

    );

  }





  //==================================================
  // COPY
  //==================================================

  GameResultModel copyWith({

    int? stars,

    int? moves,

    Duration? time,

  }){

    return GameResultModel(

      stars:
      stars ?? this.stars,


      moves:
      moves ?? this.moves,


      time:
      time ?? this.time,

    );

  }





  //==================================================
  // مقارنة النتائج
  //==================================================

  bool isBetterThan(
      GameResultModel other,
      ){

    if(stars > other.stars){

      return true;

    }


    if(stars == other.stars &&
        moves < other.moves){

      return true;

    }


    if(stars == other.stars &&
        moves == other.moves &&
        seconds < other.seconds){

      return true;

    }


    return false;

  }





  @override
  String toString(){

    return """

GameResultModel(
 stars: $stars,
 moves: $moves,
 seconds: $seconds
)

""";

  }

}