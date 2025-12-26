import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/character.dart';

class PdfUtils {
  // Экспорт PDF
  static Future<String> exportToPdf(Character character) async {
    try {
      debugPrint('Создание PDF: ${character.name}');

      // Для всех платформ возвращаем заглушку
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'character_${character.id}_$timestamp.pdf';
    } catch (e) {
      debugPrint('Ошибка при создании PDF: $e');
      return 'character_${character.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
  }

  // Предпросмотр PDF
  static Future<void> previewPdf(
      BuildContext context, Character character) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Предпросмотр PDF будет доступен в следующем обновлении'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при предпросмотре PDF: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF функциональность временно недоступна: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
