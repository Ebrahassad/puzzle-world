class GameResultModel {


  // عدد النجوم التي حصل عليها اللاعب
  final int stars;


  // عدد الحركات
  final int moves;


  // زمن إنهاء المرحلة
  final Duration time;



  const GameResultModel({

    required this.stars,

    required this.moves,

    required this.time,

  });





  // =========================
  // وقت اللعب بالثواني
  // =========================

  int get seconds {

    return time.inSeconds;

  }





  // =========================
  // تحويل إلى JSON
  // =========================

  Map<String, dynamic> toJson(){


    return {


      "stars": stars,


      "moves": moves,


      "seconds": seconds,


    };


  }





  // =========================
  // قراءة من JSON
  // =========================

  factory GameResultModel.fromJson(

      Map<String, dynamic> json,

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





  // =========================
  // تحسين النتيجة
  // =========================

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




}