import '../models/puzzle_model.dart';

class PuzzlesData {

  static const List<PuzzleModel> puzzles = [

    PuzzleModel(
      id: 'lion_1',
      title: 'الأسد',
      image: 'assets/images/puzzles/animals/lion.png',
      category: 'animals',
      pieces: 9,
    ),


    PuzzleModel(
      id: 'cat_1',
      title: 'القطة',
      image: 'assets/images/puzzles/animals/cat.png',
      category: 'animals',
      pieces: 16,
    ),


    PuzzleModel(
      id: 'car_1',
      title: 'سيارة جميلة',
      image: 'assets/images/puzzles/vehicles/car.png',
      category: 'vehicles',
      pieces: 9,
    ),


    PuzzleModel(
      id: 'city_1',
      title: 'مدينة',
      image: 'assets/images/puzzles/places/city.png',
      category: 'places',
      pieces: 25,
    ),


    PuzzleModel(
      id: 'hero_1',
      title: 'شخصية',
      image: 'assets/images/puzzles/characters/hero.png',
      category: 'characters',
      pieces: 16,
    ),

  ];


  static List<PuzzleModel> byCategory(String category){

    return puzzles
        .where((puzzle)=> puzzle.category == category)
        .toList();

  }

}
