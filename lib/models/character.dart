// lib/models/character.dart
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'class_type.dart';

class Character {
  String id;
  String name;
  CharacterClass characterClass;
  int level;
  Map<String, int> stats;
  List<String> skills;
  String background;
  String appearance;
  DateTime createdAt;

  Character({
    required this.id,
    required this.name,
    required this.characterClass,
    this.level = 1,
    required this.stats,
    required this.skills,
    required this.background,
    required this.appearance,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get maxHealth {
    return (stats['constitution']! * 5) + (level * 10);
  }

  int get attack {
    return stats['strength']! + (stats['dexterity']! ~/ 2);
  }

  int get defense {
    return stats['dexterity']! ~/ 2 + stats['constitution']! ~/ 2;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'characterClass': {
        'id': characterClass.id,
        'name': characterClass.name,
        'description': characterClass.description,
        'imageUrl': characterClass.imageUrl,
        'baseStats': characterClass.baseStats,
      },
      'level': level,
      'stats': stats,
      'skills': skills,
      'background': background,
      'appearance': appearance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      characterClass: CharacterClass(
        id: json['characterClass']['id'],
        name: json['characterClass']['name'],
        description: json['characterClass']['description'],
        imageUrl: json['characterClass']['imageUrl'],
        baseStats: Map<String, int>.from(json['characterClass']['baseStats']),
      ),
      level: json['level'],
      stats: Map<String, int>.from(json['stats']),
      skills: List<String>.from(json['skills']),
      background: json['background'],
      appearance: json['appearance'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Character copyWith({
    String? id,
    String? name,
    CharacterClass? characterClass,
    int? level,
    Map<String, int>? stats,
    List<String>? skills,
    String? background,
    String? appearance,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      stats: stats ?? Map.from(this.stats),
      skills: skills ?? List.from(this.skills),
      background: background ?? this.background,
      appearance: appearance ?? this.appearance,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  String toExportableText() {
    final buffer = StringBuffer();
    buffer.writeln('=== $name ===');
    buffer.writeln('Класс: ${characterClass.name}');
    buffer.writeln('Уровень: $level');
    buffer.writeln('Здоровье: $maxHealth');
    buffer.writeln('Атака: $attack');
    buffer.writeln('Защита: $defense');
    buffer.writeln();
    buffer.writeln('ХАРАКТЕРИСТИКИ:');

    for (final entry in stats.entries) {
      final modifier = (entry.value - 10) ~/ 2;
      final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';
      buffer.writeln(
          '${_getRussianAttributeName(entry.key)}: ${entry.value} ($modifierText)');
    }

    buffer.writeln();
    buffer.writeln('НАВЫКИ:');
    if (skills.isNotEmpty) {
      buffer.writeln(skills.map((skill) => '• $skill').join('\n'));
    } else {
      buffer.writeln('Нет навыков');
    }

    buffer.writeln();
    buffer.writeln('ПРЕДЫСТОРИЯ:');
    buffer.writeln(background);

    buffer.writeln();
    buffer.writeln('ВНЕШНОСТЬ:');
    buffer.writeln(appearance);

    buffer.writeln();
    buffer.writeln(
        'Дата создания: ${createdAt.day}.${createdAt.month}.${createdAt.year}');
    buffer.writeln();
    buffer.writeln('=== Конец записи персонажа ===');

    return buffer.toString();
  }

  String _getRussianAttributeName(String englishName) {
    const translations = {
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

String generateCharacterId() {
  return const Uuid().v4();
}
