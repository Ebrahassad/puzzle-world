class WorldProgress {


  final String worldId;


  final int completedLevels;


  final int totalLevels;


  final bool unlocked;



  const WorldProgress({

    required this.worldId,

    required this.completedLevels,

    required this.totalLevels,

    this.unlocked = false,

  });





  double get progress {


    if(totalLevels == 0){

      return 0;

    }


    return completedLevels / totalLevels;


  }





  WorldProgress copyWith({


    int? completedLevels,


    bool? unlocked,


  }){


    return WorldProgress(


      worldId: worldId,


      completedLevels:

      completedLevels ?? this.completedLevels,


      totalLevels: totalLevels,


      unlocked:

      unlocked ?? this.unlocked,


    );


  }

}
