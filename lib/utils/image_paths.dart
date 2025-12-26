// lib/utils/image_paths.dart
class ImagePaths {
  // Классы персонажей
  static const String warrior = 'assets/images/classes/warrior.png';
  static const String mage = 'assets/images/classes/mage.png';
  static const String rogue = 'assets/images/classes/rogue.png';
  static const String cleric = 'assets/images/classes/cleric.png';

  // Иконки
  static const String dice = 'assets/images/icons/dice.png';

  // Фолбэк цвета для классов
  static Map<String, int> classColors = {
    'warrior': 0xFFDC3545, // Красный
    'mage': 0xFF0D6EFD, // Синий
    'rogue': 0xFF198754, // Зеленый
    'cleric': 0xFF6F42C1, // Фиолетовый
  };

  // Получение цвета по ID класса
  static int getClassColor(String classId) {
    return classColors[classId] ?? 0xFF6C757D; // Серый по умолчанию
  }
}
