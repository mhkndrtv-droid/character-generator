import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class CharacterRepository {
  static const String _charactersKey = 'saved_characters';
  static final Logger _logger = Logger('CharacterRepository');

  CharacterRepository();

  Future<void> saveCharacter(Character character) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charactersJson = prefs.getStringList(_charactersKey) ?? [];

      final existingIndex = charactersJson.indexWhere((json) {
        try {
          final existing = Character.fromJson(jsonDecode(json));
          return existing.id == character.id;
        } catch (e) {
          return false;
        }
      });

      if (existingIndex != -1) {
        charactersJson[existingIndex] = jsonEncode(character.toJson());
        _logger.info('Персонаж ${character.id} обновлен');
      } else {
        charactersJson.add(jsonEncode(character.toJson()));
        _logger.info('Персонаж ${character.id} добавлен');
      }

      await prefs.setStringList(_charactersKey, charactersJson);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при сохранении персонажа', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Character>> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charactersJson = prefs.getStringList(_charactersKey) ?? [];

      final List<Character> characters = [];
      int errorCount = 0;

      for (final json in charactersJson) {
        try {
          final character = Character.fromJson(jsonDecode(json));
          characters.add(character);
        } catch (e, stackTrace) {
          errorCount++;
          _logger.warning('Ошибка при декодировании персонажа', e, stackTrace);
          continue;
        }
      }

      if (errorCount > 0) {
        _logger.warning(
            'Загружено ${characters.length} персонажей, $errorCount с ошибками');
      } else {
        _logger.fine('Загружено ${characters.length} персонажей');
      }

      return characters;
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при загрузке персонажей', e, stackTrace);
      return [];
    }
  }

  Future<Character?> getCharacterById(String id) async {
    final allCharacters = await getAllCharacters();
    try {
      final character = allCharacters.firstWhere((char) => char.id == id);
      _logger.fine('Найден персонаж с id: $id');
      return character;
    } catch (e) {
      _logger.fine('Персонаж с id: $id не найден');
      return null;
    }
  }

  Future<void> deleteCharacter(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charactersJson = prefs.getStringList(_charactersKey) ?? [];

      final newCharacters = <String>[];
      int deletedCount = 0;

      for (final json in charactersJson) {
        try {
          final character = Character.fromJson(jsonDecode(json));
          if (character.id != id) {
            newCharacters.add(json);
          } else {
            deletedCount++;
          }
        } catch (e) {
          newCharacters.add(json);
          continue;
        }
      }

      if (deletedCount > 0) {
        await prefs.setStringList(_charactersKey, newCharacters);
        _logger.info('Удален персонаж с id: $id');
      } else {
        _logger.fine('Персонаж с id: $id не найден для удаления');
      }
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при удалении персонажа', e, stackTrace);
      rethrow;
    }
  }

  Future<int> getCharacterCount() async {
    final prefs = await SharedPreferences.getInstance();
    final charactersJson = prefs.getStringList(_charactersKey) ?? [];
    final count = charactersJson.length;
    _logger.fine('Текущее количество персонажей: $count');
    return count;
  }

  Future<void> clearAllCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_charactersKey);
    _logger.info('Все персонажи удалены');
  }
}
