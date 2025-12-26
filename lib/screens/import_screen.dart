// lib/screens/import_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/export_utils.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final TextEditingController _jsonController = TextEditingController();
  Character? _importedCharacter;
  bool _isImporting = false;
  String _error = '';
  String _success = '';

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт персонажа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Помощь по импорту',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.import_export,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Импорт персонажа',
                            style: theme.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Вставьте JSON данные персонажа, экспортированные из приложения, '
                      'или выберите файл для импорта.',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'JSON данные персонажа:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonController,
              maxLines: 10,
              minLines: 5,
              decoration: InputDecoration(
                labelText: 'Вставьте JSON сюда',
                border: const OutlineInputBorder(),
                hintText:
                    '{"id": "...", "name": "Имя", "characterClass": {...}}',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Вставить из буфера',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearJsonField,
                      tooltip: 'Очистить поле',
                    ),
                  ],
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(76),
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importFromJson,
                    icon: const Icon(Icons.import_export),
                    label: const Text('Импортировать из JSON'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isImporting ? null : _showFilePicker,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Выбрать файл'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isImporting ? null : _validateJson,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Проверить JSON'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: colorScheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _error = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_success.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _success,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_importedCharacter != null) ...[
              const SizedBox(height: 30),
              Divider(color: colorScheme.outline.withAlpha(76)),
              const SizedBox(height: 10),
              Text(
                'Предпросмотр персонажа:',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildCharacterPreview(_importedCharacter!, theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveImportedCharacter,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: colorScheme.primary,
                  ),
                  child: const Text(
                    'Сохранить персонажа',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterPreview(Character character, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withAlpha(51),
                  radius: 30,
                  child: Text(
                    character.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          character.characterClass.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        backgroundColor: colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildPreviewStat(
                    'Уровень', character.level.toString(), Icons.star),
                _buildPreviewStat(
                    'Здоровье', character.maxHealth.toString(), Icons.favorite),
                _buildPreviewStat('Атака', character.attack.toString(),
                    Icons.sports_martial_arts),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Характеристики:',
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: character.stats.entries.map((entry) {
                return Chip(
                  label: Text(
                    '${_getAttributeName(entry.key)}: ${entry.value}',
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (character.skills.isNotEmpty) ...[
              Text(
                'Навыки:',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: character.skills.take(5).map((skill) {
                  return Chip(
                    label: Text(skill),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: colorScheme.onSurface.withAlpha(127),
                ),
                const SizedBox(width: 6),
                Text(
                  'Создан: ${character.createdAt.day}.${character.createdAt.month}.${character.createdAt.year}',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getAttributeName(String englishName) {
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

  void _pasteFromClipboard() async {
    if (!mounted) return;

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        setState(() {
          _jsonController.text = data.text!;
          _error = '';
          _success = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка доступа к буферу обмена: $e';
        });
      }
    }
  }

  void _clearJsonField() {
    setState(() {
      _jsonController.clear();
      _importedCharacter = null;
      _error = '';
      _success = '';
    });
  }

  void _validateJson() {
    final jsonString = _jsonController.text.trim();
    if (jsonString.isEmpty) {
      setState(() {
        _error = 'Введите JSON данные';
        _success = '';
      });
      return;
    }

    final isValid = ExportUtils.isValidJsonString(jsonString);
    setState(() {
      if (isValid) {
        _success = 'JSON валиден! Теперь можно импортировать.';
        _error = '';
      } else {
        _error = 'Неверный формат JSON';
        _success = '';
      }
    });
  }

  void _importFromJson() async {
    final jsonString = _jsonController.text.trim();
    if (jsonString.isEmpty) {
      setState(() {
        _error = 'Введите JSON данные';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isImporting = true;
      _error = '';
      _success = '';
      _importedCharacter = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final character = ExportUtils.importFromJsonString(jsonString);

    if (!mounted) return;

    setState(() {
      _isImporting = false;
      if (character != null) {
        _importedCharacter = character;
        _success = 'Персонаж успешно загружен!';
      } else {
        _error = 'Не удалось загрузить персонажа. Проверьте формат JSON.';
      }
    });
  }

  void _showFilePicker() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Выбор файлов будет доступен в следующем обновлении'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Помощь по импорту'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Как импортировать персонажа:'),
                SizedBox(height: 8),
                Text('1. Экспортируйте персонажа из приложения в JSON формате'),
                Text('2. Скопируйте JSON текст или сохраните файл'),
                Text('3. Вставьте JSON в поле выше или выберите файл'),
                Text('4. Нажмите "Импортировать из JSON"'),
                SizedBox(height: 16),
                Text('Формат JSON должен содержать:'),
                Text('• Имя персонажа'),
                Text('• Класс и уровень'),
                Text('• Характеристики (сила, ловкость и т.д.)'),
                Text('• Навыки и предысторию'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  void _saveImportedCharacter() async {
    if (_importedCharacter == null) return;

    final provider = Provider.of<CharacterProvider>(context, listen: false);

    try {
      if (!mounted) return;

      setState(() {
        _isImporting = true;
      });

      final success = await provider.saveCharacter(_importedCharacter!);

      if (!mounted) return;

      setState(() {
        _isImporting = false;
      });

      if (success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Персонаж успешно импортирован!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при сохранении персонажа'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isImporting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
