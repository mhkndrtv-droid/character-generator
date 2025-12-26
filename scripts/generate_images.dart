// scripts/generate_images.dart
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Для скриптов используем stderr для вывода информации
  stderr.writeln('🔄 Начинаю генерацию placeholder изображений...');

  final classesDir = Directory('assets/images/classes');
  if (!classesDir.existsSync()) {
    classesDir.createSync(recursive: true);
  }

  final iconsDir = Directory('assets/images/icons');
  if (!iconsDir.existsSync()) {
    iconsDir.createSync(recursive: true);
  }

  // Создаем изображения классов
  final classes = [
    {
      'name': 'warrior',
      'color': [220, 53, 69] // Красный
    },
    {
      'name': 'mage',
      'color': [13, 110, 253] // Синий
    },
    {
      'name': 'rogue',
      'color': [25, 135, 84] // Зеленый
    },
    {
      'name': 'cleric',
      'color': [111, 66, 193] // Фиолетовый
    },
  ];

  for (final classInfo in classes) {
    final colorList = classInfo['color'] as List<int>;
    final className = classInfo['name'] as String;

    // Создаем изображение 200x200
    final image = img.Image(width: 200, height: 200);

    // Заливаем градиентом
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        // Градиент от светлого к темному
        final factor = y / image.height;
        final r =
            (colorList[0] * (1 - factor) + colorList[0] * 0.7 * factor).toInt();
        final g =
            (colorList[1] * (1 - factor) + colorList[1] * 0.7 * factor).toInt();
        final b =
            (colorList[2] * (1 - factor) + colorList[2] * 0.7 * factor).toInt();

        final color = img.ColorRgb8(
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
        image.setPixel(x, y, color);
      }
    }

    // Сохраняем файл
    final file = File('${classesDir.path}/$className.png');
    final pngBytes = img.encodePng(image);
    file.writeAsBytesSync(pngBytes);

    stderr.writeln('✅ Создано изображение для класса: $className');
  }

  // Создаем иконку кубика
  final diceDirectory = Directory('assets/images/icons');
  if (!diceDirectory.existsSync()) {
    diceDirectory.createSync(recursive: true);
  }

  final diceImage = img.Image(width: 200, height: 200);

  // Заливаем голубым цветом
  for (int y = 0; y < diceImage.height; y++) {
    for (int x = 0; x < diceImage.width; x++) {
      final color = img.ColorRgb8(41, 128, 185); // Голубой
      diceImage.setPixel(x, y, color);
    }
  }

  final diceFile = File('${diceDirectory.path}/dice.png');
  final diceBytes = img.encodePng(diceImage);
  diceFile.writeAsBytesSync(diceBytes);

  stderr.writeln('✅ Создана иконка кубика: dice.png');
  stderr.writeln('🎉 Все placeholder изображения успешно созданы!');
  stderr.writeln('📁 Путь: ${classesDir.absolute.path}');
}
