import '../models/category_model.dart';

class PuzzleData {
  static const List<CategoryModel> categories = [

    CategoryModel(
      id: 'animals',
      name: 'الحيوانات',
      image: 'assets/images/categories/animals.png',
    ),

    CategoryModel(
      id: 'vehicles',
      name: 'المركبات',
      image: 'assets/images/categories/vehicles.png',
    ),

    CategoryModel(
      id: 'places',
      name: 'الأماكن',
      image: 'assets/images/categories/places.png',
    ),

    CategoryModel(
      id: 'characters',
      name: 'الشخصيات',
      image: 'assets/images/categories/characters.png',
    ),

  ];
}
