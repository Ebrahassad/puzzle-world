class RewardResultModel {


  // العملات
  final int coins;


  // الجواهر
  final int gems;


  // النجوم
  final int stars;


  // التلميحات
  final int hints;



  const RewardResultModel({

    this.coins = 0,

    this.gems = 0,

    this.stars = 0,

    this.hints = 0,

  });





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

    return RewardResultModel(

      coins:
      json["coins"] ?? 0,


      gems:
      json["gems"] ?? 0,


      stars:
      json["stars"] ?? 0,


      hints:
      json["hints"] ?? 0,

    );

  }





  //==================================================
  // مضاعفة المكافأة
  //==================================================

  RewardResultModel multiply(

      int value,

      ){

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