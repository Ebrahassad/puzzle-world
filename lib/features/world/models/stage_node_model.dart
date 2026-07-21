class StageNodeModel {


  final String id;


  final int level;


  final bool unlocked;


  final int stars;



  const StageNodeModel({


    required this.id,


    required this.level,


    this.unlocked = false,


    this.stars = 0,

  });



  StageNodeModel copyWith({


    bool? unlocked,


    int? stars,


  }){


    return StageNodeModel(


      id:id,


      level:level,


      unlocked:

      unlocked ?? this.unlocked,


      stars:

      stars ?? this.stars,


    );


  }

}