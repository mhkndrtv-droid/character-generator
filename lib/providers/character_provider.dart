// lib/providers/character_provider.dart
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/filter_model.dart';
import '../repositories/character_repository.dart';

class CharacterProvider with ChangeNotifier {
  final CharacterRepository _repository = CharacterRepository();
  List<Character> _characters = [];
  List<Character> _filteredCharacters = [];
  CharacterFilter _filter = CharacterFilter();
  bool _isLoading = false;
  String? _error;

  List<Character> get characters => _filteredCharacters;
  List<Character> get allCharacters => _characters;
  CharacterFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFilters => _filter.hasFilters;

  Future<void> loadCharacters() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _characters = await _repository.getAllCharacters();
      _applyFilters();

      if (kDebugMode) {
        debugPrint('Загружено ${_characters.length} персонажей');
      }
    } catch (e) {
      _error = 'Ошибка при загрузке персонажей: $e';
      if (kDebugMode) {
        debugPrint(_error!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<Character> filtered = List.from(_characters);

    if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
      final query = _filter.searchQuery!.toLowerCase();
      filtered = filtered.where((character) {
        return character.name.toLowerCase().contains(query) ||
            character.characterClass.name.toLowerCase().contains(query) ||
            character.skills
                .any((skill) => skill.toLowerCase().contains(query)) ||
            character.background.toLowerCase().contains(query);
      }).toList();
    }

    if (_filter.selectedClass != null) {
      filtered = filtered
          .where((character) =>
              character.characterClass.id == _filter.selectedClass)
          .toList();
    }

    if (_filter.minLevel != null) {
      filtered = filtered
          .where((character) => character.level >= _filter.minLevel!)
          .toList();
    }
    if (_filter.maxLevel != null) {
      filtered = filtered
          .where((character) => character.level <= _filter.maxLevel!)
          .toList();
    }

    filtered = _sortCharacters(filtered);
    _filteredCharacters = filtered;
  }

  List<Character> _sortCharacters(List<Character> characters) {
    switch (_filter.sortOption) {
      case SortOption.nameAsc:
        characters.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        characters.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.levelAsc:
        characters.sort((a, b) => a.level.compareTo(b.level));
        break;
      case SortOption.levelDesc:
        characters.sort((a, b) => b.level.compareTo(a.level));
        break;
      case SortOption.healthAsc:
        characters.sort((a, b) => a.maxHealth.compareTo(b.maxHealth));
        break;
      case SortOption.healthDesc:
        characters.sort((a, b) => b.maxHealth.compareTo(a.maxHealth));
        break;
      case SortOption.dateAsc:
        characters.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dateDesc:
        characters.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return characters;
  }

  void updateFilter(CharacterFilter newFilter) {
    _filter = newFilter;
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _filter.reset();
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(SortOption sortOption) {
    _filter = _filter.copyWith(sortOption: sortOption);
    _applyFilters();
    notifyListeners();
  }

  Future<bool> saveCharacter(Character character) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.saveCharacter(character);
      await loadCharacters();

      return true;
    } catch (e) {
      _error = 'Ошибка при сохранении персонажа: $e';
      if (kDebugMode) {
        debugPrint(_error!);
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCharacter(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteCharacter(id);
      await loadCharacters();

      return true;
    } catch (e) {
      _error = 'Ошибка при удалении персонажа: $e';
      if (kDebugMode) {
        debugPrint(_error!);
      }
      notifyListeners();
      return false;
    }
  }

  Future<Character?> getCharacter(String id) async {
    try {
      return await _repository.getCharacterById(id);
    } catch (e) {
      final errorMessage = 'Ошибка при получении персонажа: $e';
      if (kDebugMode) {
        debugPrint(errorMessage);
      }
      return null;
    }
  }

  Future<bool> updateCharacter(Character character) async {
    return await saveCharacter(character);
  }

  Future<int> getCharacterCount() async {
    try {
      return await _repository.getCharacterCount();
    } catch (e) {
      final errorMessage = 'Ошибка при получении количества персонажей: $e';
      if (kDebugMode) {
        debugPrint(errorMessage);
      }
      return 0;
    }
  }

  List<String> getUniqueClasses() {
    final classes =
        _characters.map((c) => c.characterClass.id).toSet().toList();
    classes.sort();
    return classes;
  }

  Map<String, int> getLevelRange() {
    if (_characters.isEmpty) {
      return {'min': 1, 'max': 20};
    }

    try {
      final levels = _characters.map((c) => c.level).toList();
      int minLevel = levels.reduce((a, b) => a < b ? a : b);
      int maxLevel = levels.reduce((a, b) => a > b ? a : b);

      minLevel = minLevel.clamp(1, 100);
      maxLevel = maxLevel.clamp(1, 100);

      if (maxLevel < minLevel) {
        maxLevel = minLevel;
      }

      if (minLevel == maxLevel) {
        if (minLevel == 1) {
          return {'min': 1, 'max': 5};
        } else if (maxLevel == 100) {
          return {'min': 95, 'max': 100};
        } else {
          return {
            'min': minLevel - 2 > 0 ? minLevel - 2 : 1,
            'max': maxLevel + 2 < 100 ? maxLevel + 2 : 100,
          };
        }
      }

      if (maxLevel - minLevel < 3) {
        int expandedMin = minLevel - 1;
        int expandedMax = maxLevel + 1;

        expandedMin = expandedMin.clamp(1, 100);
        expandedMax = expandedMax.clamp(1, 100);

        if (expandedMax < expandedMin) {
          expandedMax = expandedMin + 2;
        }

        if (expandedMax - expandedMin >= 3) {
          return {
            'min': expandedMin,
            'max': expandedMax,
          };
        }
      }

      return {
        'min': minLevel,
        'max': maxLevel,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Ошибка в getLevelRange: $e');
      }
      return {'min': 1, 'max': 20};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
