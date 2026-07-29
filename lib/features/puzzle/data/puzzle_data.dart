import '../models/puzzle_model.dart';


class PuzzleData {


  static const List<PuzzleModel> puzzles = [


    //==========================================
    // ANIMALS
    //==========================================

    PuzzleModel(

      id: "animals",

      title: "جزيرة الحيوانات",

      image:
      "assets/images/islands/animals_island.png",

      description:
      "اكتشف الحيوانات الجميلة وحل الألغاز الخاصة بها",

      totalLevels: 10,

      requiredStars: 0,

      order: 1,

    ),



    //==========================================
    // CARS
    //==========================================

    PuzzleModel(

      id: "cars",

      title: "جزيرة السيارات",

      image:
      "assets/images/islands/cars_island.png",

      description:
      "سيارات ومركبات ومغامرات مليئة بالتحدي",

      totalLevels: 10,

      requiredStars: 20,

      order: 2,

    ),



    //==========================================
    // NATURE
    //==========================================

    PuzzleModel(

      id: "nature",

      title: "جزيرة الطبيعة",

      image:
      "assets/images/islands/nature_island.png",

      description:
      "استكشف جمال الطبيعة وحل الألغاز الممتعة",

      totalLevels: 10,

      requiredStars: 50,

      order: 3,

    ),



    //==========================================
    // LANDMARKS
    //==========================================

    PuzzleModel(

      id: "landmarks",

      title: "جزيرة المعالم العالمية",

      image:
      "assets/images/islands/world_landmarks_island.png",

      description:
      "اكتشف أشهر المعالم حول العالم",

      totalLevels: 10,

      requiredStars: 80,

      order: 4,

    ),



    //==========================================
    // SPACE
    //==========================================

    PuzzleModel(

      id: "space",

      title: "جزيرة الفضاء",

      image:
      "assets/images/islands/space_island.png",

      description:
      "اكتشف الكواكب والصواريخ وأسرار الفضاء",

      totalLevels: 10,

      requiredStars: 100,

      order: 5,

    ),


  ];




  static PuzzleModel? getById(String id) {


    try {


      return puzzles.firstWhere(

        (island) =>
        island.id == id,

      );


    } catch (_) {


      return null;


    }


  }




  static List<PuzzleModel> get orderedPuzzles {


    final list =
    [...puzzles];


    list.sort(

      (a,b)=>
          a.order.compareTo(
              b.order
          ),

    );


    return list;


  }




  static int get count =>
      puzzles.length;



}