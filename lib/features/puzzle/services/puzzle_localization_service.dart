import '../managers/puzzle_progress_manager.dart';



class PuzzleLocalizationService {


  static Future<String> getLanguage() async {



    return await PuzzleProgressManager

        .getLanguage();


  }








  static Future<void> setLanguage(

      String language,

      ) async {



    await PuzzleProgressManager

        .saveLanguage(

      language,

    );


  }








  static String translate(

      String key,

      String language,

      ) {



    final arabic = {



      "puzzle": "بازل",


      "level": "مرحلة",


      "stars": "نجوم",


      "completed": "مكتمل",


      "locked": "مغلق",


      "reward": "مكافأة",


      "hint": "مساعدة",


      "play": "ابدأ",


    };





    final english = {



      "puzzle": "Puzzle",


      "level": "Level",


      "stars": "Stars",


      "completed": "Completed",


      "locked": "Locked",


      "reward": "Reward",


      "hint": "Hint",


      "play": "Play",


    };





    if(language == "en"){



      return english[key] ?? key;


    }





    return arabic[key] ?? key;


  }








  static List<String> availableLanguages(){



    return [


      "ar",


      "en",


    ];


  }


}