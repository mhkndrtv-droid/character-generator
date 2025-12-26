// lib/models/class_type.dart
class CharacterClass {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final Map<String, int> baseStats;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.baseStats,
  });
}
