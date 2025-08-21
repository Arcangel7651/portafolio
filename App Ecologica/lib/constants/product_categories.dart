// lib/constants/product_categories.dart
class ProductCategories {
  static const String todos = 'todos';
  static const String electronico = 'Electrónico';
  static const String ropa = 'Ropa';
  static const String mueble = 'Mueble';
  static const String cocina = 'Cocina';
  static const String otros = 'Otros';

  static List<String> get values => [electronico, ropa, mueble, cocina, otros];

  static List<String> estados = [
    'Nuevo',
    'Semi Nuevo',
    'Usado',
  ];
}
