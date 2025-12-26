import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character.dart';
import 'pdf_utils.dart';
import 'simple_image_generator.dart';

class ExportUtils {
  static Future<String> exportToFile(Character character, String format) async {
    try {
      String fileName;
      String content;

      switch (format) {
        case 'json':
          fileName =
              '${character.name}_${DateTime.now().millisecondsSinceEpoch}.json';
          content = character.toFormattedJson();
          return await _saveFile(character, fileName, content, format);

        case 'txt':
          fileName =
              '${character.name}_${DateTime.now().millisecondsSinceEpoch}.txt';
          content = character.toExportableText();
          return await _saveFile(character, fileName, content, format);

        case 'pdf':
          return await PdfUtils.exportToPdf(character);

        case 'image':
          return await SimpleImageGenerator.generateSimpleImage(character);

        default:
          throw Exception('Неподдерживаемый формат: $format');
      }
    } catch (e) {
      debugPrint('Ошибка при экспорте: $e');
      rethrow;
    }
  }

  static Future<String> _saveFile(Character character, String fileName,
      String content, String format) async {
    if (kIsWeb) {
      return await _saveFileForWeb(fileName, content, format);
    } else {
      return await _saveFileForMobile(fileName, content);
    }
  }

  static Future<String> _saveFileForWeb(
      String fileName, String content, String format) async {
    try {
      // Для Web просто возвращаем имя файла
      return fileName;
    } catch (e) {
      debugPrint('Ошибка при сохранении файла для Web: $e');
      rethrow;
    }
  }

  static Future<String> _saveFileForMobile(
      String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      debugPrint('Ошибка при сохранении файла для мобильной платформы: $e');
      return '/tmp/$fileName';
    }
  }

  static Character? importFromJsonString(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString);
      return Character.fromJson(jsonData);
    } catch (e) {
      debugPrint('Ошибка импорта из JSON: $e');
      return null;
    }
  }

  static Future<void> shareCharacter(
      Character character, BuildContext context) async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF документ'),
                  subtitle: const Text('Формальный лист персонажа'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareInFormat(character, 'pdf', context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Изображение'),
                  subtitle: const Text('Картинка персонажа'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareInFormat(character, 'image', context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Текстовый формат (.txt)'),
                  subtitle: const Text('Для быстрого обмена в мессенджерах'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareInFormat(character, 'txt', context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('JSON формат (.json)'),
                  subtitle: const Text('Для импорта обратно в приложение'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareInFormat(character, 'json', context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Отмена'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  static Future<void> _shareInFormat(
      Character character, String format, BuildContext context) async {
    try {
      if (kIsWeb) {
        await _shareInFormatWeb(character, format, context);
      } else {
        await _shareInFormatMobile(character, format, context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _shareInFormatWeb(
      Character character, String format, BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Подготовка файла...'),
            ],
          ),
        ),
      );

      String content;
      String subject;
      String formatDescription;

      switch (format) {
        case 'json':
          content = character.toFormattedJson();
          subject = 'Персонаж ${character.name} (JSON)';
          formatDescription = 'JSON формате';
          break;
        case 'txt':
          content = character.toExportableText();
          subject = 'Персонаж ${character.name} (Текст)';
          formatDescription = 'текстовом формате';
          break;
        case 'pdf':
          content = character.toExportableText();
          subject = 'Персонаж ${character.name} (PDF)';
          formatDescription = 'PDF формате';
          break;
        case 'image':
          content = character.toExportableText();
          subject = 'Персонаж ${character.name} (Изображение)';
          formatDescription = 'формате изображения';
          break;
        default:
          content = character.toExportableText();
          subject = 'Персонаж ${character.name}';
          formatDescription = 'текстовом формате';
      }

      if (context.mounted) {
        Navigator.pop(context);
      }

      // Используем Share.share для Web платформы
      await Share.share(
        content,
        subject: subject,
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 2,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Персонаж готов к отправке в $formatDescription'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _shareInFormatMobile(
      Character character, String format, BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Создание ${format.toUpperCase()}...'),
            ],
          ),
        ),
      );

      final filePath = await exportToFile(character, format);

      if (context.mounted) {
        Navigator.pop(context);
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Персонаж: ${character.name}',
        subject: 'Персонаж для RPG игры',
      );

      // Удаляем временный файл через 5 минут
      Future.delayed(const Duration(minutes: 5), () {
        try {
          final file = File(filePath);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          debugPrint('Ошибка при удалении файла: $e');
        }
      });
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static bool isValidJsonString(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> exportToPdf(Character character) async {
    return await PdfUtils.exportToPdf(character);
  }

  static Future<void> previewPdf(
      BuildContext context, Character character) async {
    return await PdfUtils.previewPdf(context, character);
  }

  static Future<String> generateSimpleImage(Character character) async {
    return await SimpleImageGenerator.generateSimpleImage(character);
  }
}
