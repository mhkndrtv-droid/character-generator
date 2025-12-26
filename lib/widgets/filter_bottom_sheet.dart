// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../models/filter_model.dart';
import '../providers/character_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final CharacterProvider provider;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.provider,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late CharacterFilter _filter;
  late RangeValues _levelRange;

  @override
  void initState() {
    super.initState();
    _filter = widget.provider.filter.copyWith();

    final levelRange = widget.provider.getLevelRange();
    _levelRange = RangeValues(
      _filter.minLevel?.toDouble() ?? levelRange['min']!.toDouble(),
      _filter.maxLevel?.toDouble() ?? levelRange['max']!.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = widget.provider.getUniqueClasses();
    final levelRange = widget.provider.getLevelRange();

    final minLevel = levelRange['min']!;
    final maxLevel = levelRange['max']!;
    final int? divisions = maxLevel > minLevel ? maxLevel - minLevel : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Фильтры и сортировка',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Сортировка:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortOption.values.map((option) {
              final isSelected = _filter.sortOption == option;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(option.icon, size: 16),
                    const SizedBox(width: 4),
                    Text(option.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filter = _filter.copyWith(sortOption: option);
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withAlpha(50),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Класс:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Все классы'),
                selected: _filter.selectedClass == null,
                onSelected: (selected) {
                  setState(() {
                    _filter = _filter.copyWith(selectedClass: null);
                  });
                },
              ),
              ...classes.map((classId) {
                final isSelected = _filter.selectedClass == classId;
                return FilterChip(
                  label: Text(classId),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _filter = _filter.copyWith(
                        selectedClass: selected ? classId : null,
                      );
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Уровень:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _levelRange,
            min: minLevel.toDouble(),
            max: maxLevel.toDouble(),
            divisions: divisions,
            labels: RangeLabels(
              _levelRange.start.round().toString(),
              _levelRange.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _levelRange = values;
              });
            },
            onChangeEnd: (values) {
              _filter = _filter.copyWith(
                minLevel: values.start.round(),
                maxLevel: values.end.round(),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('От: ${_levelRange.start.round()}'),
              Text('До: ${_levelRange.end.round()}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Сбросить'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.provider.updateFilter(_filter);
                    widget.onApply();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
