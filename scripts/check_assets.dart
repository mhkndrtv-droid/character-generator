// scripts/check_assets.dart
// ignore_for_file: avoid_print, unnecessary_string_interpolations
import 'dart:io';

void main() {
  print('🔍 Проверяю изображения в assets...');

  const requiredImages = [
    'assets/images/classes/warrior.png',
    'assets/images/classes/mage.png',
    'assets/images/classes/rogue.png',
    'assets/images/classes/cleric.png',
    'assets/images/icons/dice.png',
  ];

  var allExist = true;

  for (final path in requiredImages) {
    final file = File(path);
    if (file.existsSync()) {
      final size = file.lengthSync();
      final sizeInKb = (size / 1024).toStringAsFixed(1);
      print('✅ $path - $sizeInKb КБ');
    } else {
      print('❌ $path - НЕ НАЙДЕН');
      allExist = false;
    }
  }

  if (!allExist) {
    print('');
    print('⚠️  Создайте недостающие изображения:');
    print('   mkdir -p assets/images/{classes,icons}');
    print('   # Добавьте PNG файлы в эти папки');
  } else {
    print('');
    print('🎉 Все изображения на месте!');
  }
}
