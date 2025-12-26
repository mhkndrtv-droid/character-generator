// lib/widgets/attribute_slider.dart
import 'package:flutter/material.dart';

class AttributeSlider extends StatelessWidget {
  final String attributeName;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const AttributeSlider({
    super.key,
    required this.attributeName,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attributeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getValueColor(value),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (isDarkMode)
                        BoxShadow(
                          color: Colors.black.withAlpha(76),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                    ],
                  ),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor:
                    isDarkMode ? Colors.grey[700] : Colors.grey[300],
                thumbColor: theme.colorScheme.primary,
                overlayColor: theme.colorScheme.primary.withAlpha(51),
                valueIndicatorColor: theme.colorScheme.primary,
                activeTickMarkColor: theme.colorScheme.primary,
              ),
              child: Slider(
                value: value.toDouble(),
                min: minValue.toDouble(),
                max: maxValue.toDouble(),
                divisions: maxValue - minValue > 0 ? maxValue - minValue : null,
                label: value.toString(),
                onChanged: (newValue) {
                  onChanged(newValue.round());
                },
              ),
            ),
            Text(
              _getModifierDescription(value),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withAlpha(153),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getValueColor(int value) {
    if (value >= 16) return Colors.red;
    if (value >= 14) return Colors.orange;
    if (value >= 12) return Colors.green;
    if (value >= 10) return Colors.blue;
    return Colors.grey;
  }

  String _getModifierDescription(int value) {
    final modifier = (value - 10) ~/ 2;
    final sign = modifier >= 0 ? '+' : '';

    if (modifier >= 3) return 'Выдающийся ($sign$modifier)';
    if (modifier >= 1) return 'Хороший ($sign$modifier)';
    if (modifier == 0) return 'Средний ($sign$modifier)';
    if (modifier >= -1) return 'Слабый ($sign$modifier)';
    return 'Очень слабый ($sign$modifier)';
  }
}
