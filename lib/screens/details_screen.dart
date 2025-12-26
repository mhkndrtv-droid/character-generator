// lib/screens/details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/character_provider.dart';
import '../models/character.dart';
import '../utils/export_utils.dart';

class DetailsScreen extends StatefulWidget {
  final Character character;
  final bool isNewCharacter;

  const DetailsScreen({
    super.key,
    required this.character,
    this.isNewCharacter = true,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isSaving = false;

  Future<void> _handleExportMenu(String value) async {
    if (!mounted) return;

    switch (value) {
      case 'export_json':
        await _exportCharacter('json');
        break;
      case 'export_txt':
        await _exportCharacter('txt');
        break;
      case 'copy_text':
        await _copyCharacterText();
        break;
      case 'view_json':
        _viewCharacterJson();
        break;
      case 'export_pdf':
        await _exportPdf();
        break;
      case 'export_image':
        await _exportImage();
        break;
      case 'preview_pdf':
        await _previewPdf();
        break;
      default:
        break;
    }
  }

  Future<void> _exportCharacter(String format) async {
    if (!mounted) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final filePath = await ExportUtils.exportToFile(widget.character, format);
      debugPrint('Файл экспортирован в: $filePath');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Персонаж экспортирован в формате $format', isError: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Ошибка экспорта: $e', isError: true);
    }
  }

  Future<void> _copyCharacterText() async {
    if (!mounted) return;

    try {
      await Clipboard.setData(
        ClipboardData(text: widget.character.toExportableText()),
      );

      _showSnackBar('Текст персонажа скопирован в буфер обмена!',
          isError: false);
    } catch (e) {
      _showSnackBar('Ошибка копирования: $e', isError: true);
    }
  }

  void _viewCharacterJson() {
    if (!mounted) return;

    final jsonText = widget.character.toFormattedJson();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('JSON персонажа'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            TextButton(
              onPressed: () async {
                final localContext = context;
                await Clipboard.setData(ClipboardData(text: jsonText));
                if (localContext.mounted) {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    const SnackBar(
                      content: Text('JSON скопирован!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Копировать'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportPdf() async {
    if (!mounted) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final filePath = await ExportUtils.exportToPdf(widget.character);
      debugPrint('PDF экспортирован в: $filePath');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('PDF документ создан!', isError: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Ошибка при создании PDF: $e', isError: true);
    }
  }

  Future<void> _exportImage() async {
    if (!mounted) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final filePath = await ExportUtils.generateSimpleImage(widget.character);
      debugPrint('Изображение экспортировано в: $filePath');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Изображение создано!', isError: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Ошибка при создании изображения: $e', isError: true);
    }
  }

  Future<void> _previewPdf() async {
    if (!mounted) return;

    try {
      await ExportUtils.previewPdf(context, widget.character);
    } catch (e) {
      _showSnackBar('Ошибка при предпросмотре PDF: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.character.name,
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              if (mounted) {
                ExportUtils.shareCharacter(widget.character, context);
              }
            },
            tooltip: 'Экспортировать персонажа',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.appBarTheme.foregroundColor,
            ),
            onSelected: (value) async {
              if (mounted) {
                await _handleExportMenu(value);
              }
            },
            itemBuilder: (context) => [
              if (!kIsWeb)
                const PopupMenuItem(
                  value: 'preview_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.preview, size: 20),
                      SizedBox(width: 10),
                      Text('Предпросмотр PDF'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 10),
                    Text('Экспорт в PDF файл'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_image',
                child: Row(
                  children: [
                    Icon(Icons.image, size: 20),
                    SizedBox(width: 10),
                    Text('Экспорт в изображение'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 20),
                    SizedBox(width: 10),
                    Text('Экспорт в JSON файл'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_txt',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 20),
                    SizedBox(width: 10),
                    Text('Экспорт в текстовый файл'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_text',
                child: Row(
                  children: [
                    Icon(Icons.content_copy, size: 20),
                    SizedBox(width: 10),
                    Text('Скопировать текст персонажа'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view_json',
                child: Row(
                  children: [
                    Icon(Icons.preview, size: 20),
                    SizedBox(width: 10),
                    Text('Просмотреть JSON'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withAlpha(25),
                          theme.colorScheme.secondaryContainer.withAlpha(13),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withAlpha(51),
                            radius: 40,
                            child: Text(
                              widget.character.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.character.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Chip(
                                label: Text(
                                  widget.character.characterClass.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
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
                              _buildStatCard(
                                theme,
                                'Уровень',
                                widget.character.level.toString(),
                              ),
                              _buildStatCard(
                                theme,
                                'Здоровье',
                                widget.character.maxHealth.toString(),
                              ),
                              _buildStatCard(
                                theme,
                                'Атака',
                                widget.character.attack.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assessment,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Характеристики',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: widget.character.stats.entries.map((entry) {
                    return _buildAttributeCard(theme, entry.key, entry.value);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  theme,
                  title: 'Навыки',
                  content: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.character.skills.map((skill) {
                      return Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withAlpha(51),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _buildSection(
                  theme,
                  title: 'Предыстория',
                  content: Text(
                    widget.character.background,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withAlpha(229),
                    ),
                  ),
                ),
                _buildSection(
                  theme,
                  title: 'Внешность',
                  content: Text(
                    widget.character.appearance,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withAlpha(229),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withAlpha(25),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          icon: Icon(
                            Icons.edit,
                            color: _isSaving
                                ? theme.colorScheme.outline
                                : theme.colorScheme.primary,
                          ),
                          label: Text(
                            'Изменить',
                            style: TextStyle(
                              color: _isSaving
                                  ? theme.colorScheme.outline
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: _isSaving
                                  ? theme.colorScheme.outline
                                  : theme.colorScheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveCharacter,
                          icon: Icon(
                            Icons.save,
                            color: _isSaving
                                ? theme.colorScheme.onSurface.withAlpha(127)
                                : theme.colorScheme.onPrimary,
                          ),
                          label: Text(
                            widget.isNewCharacter ? 'Сохранить' : 'Обновить',
                            style: TextStyle(
                              color: _isSaving
                                  ? theme.colorScheme.onSurface.withAlpha(127)
                                  : theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaving
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withAlpha(127),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Сохранение...',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeCard(ThemeData theme, String attributeKey, int value) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final modifier = (value - 10) ~/ 2;
    final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';
    final attributeName = _getRussianAttributeName(attributeKey);

    Color getLocalValueColor(int val) {
      if (val >= 16) return theme.colorScheme.error;
      if (val >= 14) return theme.colorScheme.tertiary;
      if (val >= 12) return theme.colorScheme.primary;
      if (val >= 10) return theme.colorScheme.secondary;
      return theme.colorScheme.outlineVariant;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          attributeName,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Модификатор: $modifierText',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getLocalValueColor(value),
            shape: BoxShape.circle,
            boxShadow: [
              if (isDarkMode)
                BoxShadow(
                  color: theme.colorScheme.shadow.withAlpha(76),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              BoxShadow(
                color: getLocalValueColor(value).withAlpha(76),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                getLocalValueColor(value),
                getLocalValueColor(value).withAlpha(204),
              ],
            ),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme,
      {required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(25),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSectionIcon(title),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Навыки':
        return Icons.stars;
      case 'Предыстория':
        return Icons.history_edu;
      case 'Внешность':
        return Icons.face;
      default:
        return Icons.info;
    }
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

  Future<void> _saveCharacter() async {
    if (_isSaving || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    try {
      final success = await characterProvider.saveCharacter(widget.character);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (success) {
        _showSnackBar('Персонаж сохранен!', isError: false);
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Ошибка при сохранении персонажа', isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Ошибка: ${e.toString()}', isError: true);
    }
  }
}
