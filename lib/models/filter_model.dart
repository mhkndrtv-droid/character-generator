// lib/models/filter_model.dart
import 'package:flutter/material.dart';

class CharacterFilter {
  String? searchQuery;
  String? selectedClass;
  int? minLevel;
  int? maxLevel;
  SortOption sortOption;

  CharacterFilter({
    this.searchQuery,
    this.selectedClass,
    this.minLevel,
    this.maxLevel,
    this.sortOption = SortOption.dateDesc,
  });

  CharacterFilter copyWith({
    String? searchQuery,
    String? selectedClass,
    int? minLevel,
    int? maxLevel,
    SortOption? sortOption,
  }) {
    return CharacterFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClass: selectedClass ?? this.selectedClass,
      minLevel: minLevel ?? this.minLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get hasFilters {
    return searchQuery != null ||
        selectedClass != null ||
        minLevel != null ||
        maxLevel != null ||
        sortOption != SortOption.dateDesc;
  }

  void reset() {
    searchQuery = null;
    selectedClass = null;
    minLevel = null;
    maxLevel = null;
    sortOption = SortOption.dateDesc;
  }
}

enum SortOption {
  nameAsc('По имени (А-Я)', Icons.sort_by_alpha),
  nameDesc('По имени (Я-А)', Icons.sort_by_alpha),
  levelAsc('По уровню (возр.)', Icons.arrow_upward),
  levelDesc('По уровню (убыв.)', Icons.arrow_downward),
  dateAsc('По дате (старые)', Icons.calendar_today),
  dateDesc('По дате (новые)', Icons.calendar_today),
  healthAsc('По здоровью (возр.)', Icons.favorite),
  healthDesc('По здоровью (убыв.)', Icons.favorite);

  final String label;
  final IconData icon;

  const SortOption(this.label, this.icon);
}
