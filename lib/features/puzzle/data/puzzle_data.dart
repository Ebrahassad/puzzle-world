import '../models/puzzle_model.dart';


class PuzzleData {


  static const List<PuzzleModel> puzzles = [


    PuzzleModel(

      id: "animals",

      title: "جزيرة الحيوانات",

      image:
      "assets/images/islands/animals_island.webp",

      description:
      "اكتشف الحيوانات الجميلة وحل الألغاز الخاصة بها",

      totalLevels: 10,

      requiredStars: 0,

      order: 1,

    ),



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



    PuzzleModel(

      id: "space",

      title: "جزيرة الفضاء",

      image:
      "assets/images/islands/space_island.png",

      description:
      "اكتشف الكواكب والصواريخ وأسرار الفضاء",

      totalLevels: 10,

      requiredStars: 50,

      order: 3,

    ),



    PuzzleModel(

      id: "nature",

      title: "جزيرة الطبيعة",

      image:
      "assets/images/islands/natural_island.png",

      description:
      "استكشف جمال الطبيعة وحل الألغاز الممتعة",

      totalLevels: 10,

      requiredStars: 80,

      order: 4,

    ),



    PuzzleModel(

      id: "landmarks",

      title: "جزيرة المعالم",

      image:
      "assets/images/islands/city_island.jpg",

      description:
      "اكتشف أشهر المعالم حول العالم وحل الألغاز الممتعة",

      totalLevels: 10,

      requiredStars: 100,

      order: 5,

    ),


  ];




  // جلب جزيرة بواسطة المعرف

  static PuzzleModel? getById(
      String id,
      ) {

    try {

      return puzzles.firstWhere(
            (world) => world.id == id,
      );

    } catch (_) {

      return null;

    }

  }




  // جلب جميع الجزر مرتبة

  static List<PuzzleModel> get orderedPuzzles {

    final list = [...puzzles];

    list.sort(
          (a, b) => a.order.compareTo(b.order),
    );

    return list;

  }




  // عدد الجزر

  static int get count => puzzles.length;


}