class RewardResultModel {


  // العملات
  final int coins;


  // الجواهر
  final int gems;


  // النجوم الذهبية Golden Star
  final int stars;


  // التلميحات
  final int hints;





  const RewardResultModel({

    this.coins = 0,

    this.gems = 0,

    this.stars = 0,

    this.hints = 0,

  })
      : assert(coins >= 0),
        assert(gems >= 0),
        assert(stars >= 0),
        assert(hints >= 0);









  //==================================================
  // هل توجد مكافأة
  //==================================================

  bool get hasReward {


    return coins > 0 ||

        gems > 0 ||

        stars > 0 ||

        hints > 0;


  }









  //==================================================
  // هل توجد Golden Star
  //==================================================

  bool get hasGoldenStar {


    return stars > 0;


  }









  //==================================================
  // JSON
  //==================================================

  Map<String,dynamic> toJson(){


    return {


      "coins": coins,


      "gems": gems,


      "stars": stars,


      "hints": hints,


    };


  }









  //==================================================
  // FROM JSON
  //==================================================

  factory RewardResultModel.fromJson(

      Map<String,dynamic> json,

      ){



    int value(dynamic data){


      if(data is int && data >= 0){

        return data;

      }


      return 0;


    }






    return RewardResultModel(


      coins:

      value(json["coins"]),



      gems:

      value(json["gems"]),



      stars:

      value(json["stars"]),



      hints:

      value(json["hints"]),



    );


  }









  //==================================================
  // مضاعفة المكافأة
  //==================================================

  RewardResultModel multiply(

      int value,

      ){



    if(value <= 0){

      return this;

    }







    return RewardResultModel(


      coins:

      coins * value,



      gems:

      gems * value,



      stars:

      stars * value,



      hints:

      hints * value,



    );


  }









  //==================================================
  // دمج مكافأتين
  //==================================================

  RewardResultModel merge(

      RewardResultModel other,

      ){



    return RewardResultModel(


      coins:

      coins + other.coins,



      gems:

      gems + other.gems,



      stars:

      stars + other.stars,



      hints:

      hints + other.hints,



    );


  }









  //==================================================
  // COPY
  //==================================================

  RewardResultModel copyWith({

    int? coins,

    int? gems,

    int? stars,

    int? hints,

  }){


    return RewardResultModel(


      coins: coins ?? this.coins,


      gems: gems ?? this.gems,


      stars: stars ?? this.stars,


      hints: hints ?? this.hints,


    );


  }









  @override

  String toString(){


    return """

RewardResultModel(
 coins: $coins,
 gems: $gems,
 stars: $stars,
 hints: $hints
)

""";


  }


}