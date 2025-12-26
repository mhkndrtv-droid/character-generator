import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../models/character.dart';

class SimpleImageGenerator {
  static Future<String> generateSimpleImage(Character character) async {
    if (kIsWeb) {
      // Для Web возвращаем текстовый файл вместо изображения
      return await _createTextFile(character);
    }

    try {
      // Код для мобильных платформ остается прежним
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();

      const double width = 800.0;
      const double height = 600.0;

      paint.color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

      final paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 14,
        ),
      );

      paragraphBuilder
        ..pushStyle(ui.TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: ui.FontWeight.bold,
        ))
        ..addText('${character.name}\n\n')
        ..pop()
        ..pushStyle(ui.TextStyle(
          color: Colors.blue,
          fontSize: 18,
        ))
        ..addText('Класс: ${character.characterClass.name}\n')
        ..addText('Уровень: ${character.level}\n')
        ..addText('Здоровье: ${character.maxHealth}\n')
        ..addText('Атака: ${character.attack}\n')
        ..addText('Защита: ${character.defense}\n\n')
        ..pop()
        ..pushStyle(ui.TextStyle(
          color: Colors.grey.shade800,
          fontSize: 16,
        ))
        ..addText('Характеристики:\n');

      for (final entry in character.stats.entries) {
        final modifier = (entry.value - 10) ~/ 2;
        final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';
        paragraphBuilder.addText(
            '  ${_getRussianAttributeName(entry.key)}: ${entry.value} ($modifierText)\n');
      }

      paragraphBuilder
        ..addText('\nНавыки:\n')
        ..addText('  ${character.skills.join(", ")}\n\n')
        ..addText('Дата создания: ')
        ..pushStyle(ui.TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontStyle: ui.FontStyle.italic,
        ))
        ..addText('${character.createdAt.day}.'
            '${character.createdAt.month}.${character.createdAt.year}');

      final paragraph = paragraphBuilder.build();
      paragraph.layout(const ui.ParagraphConstraints(width: 760.0));
      canvas.drawParagraph(paragraph, const Offset(20, 20));

      final picture = recorder.endRecording();
      final image = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${character.name.replaceAll(RegExp(r'[^\w\s]'), '_')}_$timestamp.png';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      debugPrint('Ошибка при создании изображения: $e');
      return await _createTextFile(character);
    }
  }

  static Future<String> _createTextFile(Character character) async {
    if (kIsWeb) {
      // Для Web возвращаем просто имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${character.name.replaceAll(RegExp(r'[^\w\s]'), '_')}_$timestamp.txt';
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${character.name.replaceAll(RegExp(r'[^\w\s]'), '_')}_$timestamp.txt';
    final filePath = '${directory.path}/$fileName';

    final content = '''
ПЕРСОНАЖ: ${character.name}
Класс: ${character.characterClass.name}
Уровень: ${character.level}
Здоровье: ${character.maxHealth}
Атака: ${character.attack}
Защита: ${character.defense}

ХАРАКТЕРИСТИКИ:
${character.stats.entries.map((e) => '  ${_getRussianAttributeName(e.key)}: ${e.value}').join('\n')}

НАВЫКИ:
${character.skills.map((s) => '  • $s').join('\n')}

Предыстория: ${character.background}

Внешность: ${character.appearance}

Дата создания: ${character.createdAt.day}.${character.createdAt.month}.${character.createdAt.year}
''';

    final file = File(filePath);
    await file.writeAsString(content);

    return filePath;
  }

  static String _getRussianAttributeName(String englishName) {
    const Map<String, String> translations = {
      'strength': 'Сила',
      'dexterity': 'Ловкость',
      'constitution': 'Телосложение',
      'intelligence': 'Интеллект',
      'wisdom': 'Мудрость',
      'charisma': 'Харизма',
    };
    return translations[englishName] ?? englishName;
  }
}
