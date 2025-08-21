// lib/services/user_data.dart
class UserData {
  static String? _userId; // Variable privada

  // Getter para acceder al valor de userId
  static String? get userId => _userId;

  // Setter para modificar el valor de userId
  static set userId(String? id) {
    _userId = id;
  }
}
