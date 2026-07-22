import '../models/puzzle_model.dart';



class PuzzleData {


  static const List<PuzzleModel> puzzles = [



    PuzzleModel(

      id: "animals",

      title: "عالم الحيوانات 🐻",

      image:
      "assets/images/Puzzle/animals.png",

      description:
      "اكتشف الحيوانات الجميلة وحل البازل الخاص بها",

      totalLevels: 10,

      unlocked: true,

      requiredStars: 0,

    ),





    PuzzleModel(

      id: "nature",

      title: "عالم الطبيعة 🌳",

      image:
      "assets/images/Puzzle/nature.png",

      description:
      "مناظر طبيعية وألغاز ممتعة",

      totalLevels: 10,

      unlocked: false,

      requiredStars: 20,

    ),





    PuzzleModel(

      id: "vehicles",

      title: "عالم السيارات 🚗",

      image:
      "assets/images/Puzzle/vehicles.png",

      description:
      "سيارات ومركبات بطريقة تعليمية",

      totalLevels: 10,

      unlocked: false,

      requiredStars: 50,

    ),





    PuzzleModel(

      id: "fruits",

      title: "عالم الفواكه 🍎",

      image:
      "assets/images/Puzzle/fruits.png",

      description:
      "تعلم الفواكه من خلال اللعب",

      totalLevels: 10,

      unlocked: false,

      requiredStars: 80,

    ),



  ];





  // جلب عالم بواسطة المعرف

  static PuzzleModel? getById(
      String id,
      ){

    try {

      return puzzles.firstWhere(
            (world) => world.id == id,
      );

    } catch (_) {

      return null;

    }

  }





  // عدد العوالم

  static int get count => puzzles.length;


}