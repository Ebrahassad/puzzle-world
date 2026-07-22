class RewardResultModel {


  final int coins;


  final int gems;



  const RewardResultModel({


    required this.coins,


    required this.gems,


  });





  // تحويل إلى Map للحفظ مستقبلاً

  Map<String, dynamic> toJson(){


    return {


      "coins": coins,


      "gems": gems,


    };


  }





  // قراءة من Map

  factory RewardResultModel.fromJson(

      Map<String, dynamic> json,

      ){


    return RewardResultModel(


      coins: json["coins"] ?? 0,


      gems: json["gems"] ?? 0,


    );


  }





  // دمج المكافآت (مثلاً مضاعفة الإعلان)

  RewardResultModel multiply(

      int value,

      ){


    return RewardResultModel(


      coins: coins * value,


      gems: gems * value,


    );


  }




}
