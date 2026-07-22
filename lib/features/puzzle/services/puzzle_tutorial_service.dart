import '../managers/puzzle_progress_manager.dart';



class PuzzleTutorialService {


  static Future<bool> isCompleted() async {



    return await PuzzleProgressManager

        .isTutorialCompleted();


  }








  static Future<void> complete() async {



    await PuzzleProgressManager

        .completeTutorial();


  }








  static Future<void> reset() async {



    await PuzzleProgressManager

        .resetTutorial();


  }








  static List<Map<String, String>>

  getSteps() {



    return [



      {


        "title": "حرك القطعة",


        "description":

        "اسحب قطع الصورة وضعها في المكان الصحيح",



      },





      {


        "title": "طابق الصورة",


        "description":

        "رتب جميع القطع حتى تكتمل الصورة",



      },





      {


        "title": "اجمع النجوم",


        "description":

        "أنهِ المراحل لتحصل على نجوم ومكافآت",



      },





      {


        "title": "استخدم المساعدة",


        "description":

        "يمكنك استخدام النجوم أو الإعلانات للحصول على تلميحات",



      },



    ];



  }








  static int getStepsCount(){



    return getSteps().length;


  }


}