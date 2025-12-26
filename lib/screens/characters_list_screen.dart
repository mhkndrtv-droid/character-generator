// lib/screens/characters_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../models/filter_model.dart';
import '../providers/character_provider.dart';
import 'details_screen.dart';
import 'import_screen.dart';
import '../widgets/filter_bottom_sheet.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CharacterProvider>(context, listen: false);
      provider.loadCharacters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои персонажи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportScreen()),
              );
            },
            tooltip: 'Импорт персонажа',
          ),
          if (characterProvider.allCharacters.isNotEmpty)
            _buildFilterActionButton(characterProvider, theme),
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Информация',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(characterProvider, theme),
          Expanded(
            child: _buildBody(characterProvider, theme),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'import_btn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportScreen()),
              );
            },
            backgroundColor: Colors.blue,
            tooltip: 'Импорт персонажа',
            child: const Icon(Icons.file_upload, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'home_btn',
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'На главную',
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CharacterProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            provider.setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Поиск по имени, классу, навыкам...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterActionButton(CharacterProvider provider, ThemeData theme) {
    return Badge(
      isLabelVisible: provider.hasFilters,
      backgroundColor: theme.colorScheme.primary,
      child: IconButton(
        onPressed: () => _showFilterDialog(context, provider),
        icon: const Icon(Icons.filter_list),
        tooltip: 'Фильтры и сортировка',
      ),
    );
  }

  Widget _buildBody(CharacterProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Ошибка загрузки',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.loadCharacters(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (provider.characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              provider.allCharacters.isEmpty
                  ? 'Пока нет персонажей'
                  : 'Ничего не найдено',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              provider.allCharacters.isEmpty
                  ? 'Создайте своего первого персонажа!'
                  : 'Попробуйте изменить параметры поиска',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            if (provider.allCharacters.isEmpty)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Создать персонажа'),
              ),
            if (provider.allCharacters.isNotEmpty && provider.hasFilters)
              ElevatedButton(
                onPressed: () => provider.resetFilters(),
                child: const Text('Сбросить фильтры'),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatisticsAndFilterInfo(provider, theme),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.characters.length,
            itemBuilder: (context, index) {
              final character = provider.characters[index];
              return _buildCharacterCard(character, theme, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsAndFilterInfo(
      CharacterProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (provider.hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Показано ${provider.characters.length} из ${provider.allCharacters.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.resetFilters(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Сбросить',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    theme,
                    Icons.people,
                    'Всего',
                    provider.allCharacters.length.toString(),
                  ),
                  _buildStatItem(
                    theme,
                    Icons.star,
                    'Макс. уровень',
                    provider.allCharacters
                        .map((c) => c.level)
                        .reduce((a, b) => a > b ? a : b)
                        .toString(),
                  ),
                  _buildStatItem(
                    theme,
                    Icons.category,
                    'Классы',
                    provider.allCharacters
                        .map((c) => c.characterClass.id)
                        .toSet()
                        .length
                        .toString(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(
    Character character,
    ThemeData theme,
    CharacterProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openCharacterDetails(character);
        },
        onLongPress: () {
          _showCharacterOptions(character, provider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCharacterAvatar(character, theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            character.name,
                            style: theme.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Chip(
                          backgroundColor: theme.colorScheme.primary,
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            'Ур. ${character.level}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.characterClass.name,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCharacterStats(character, theme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${character.createdAt.day}.${character.createdAt.month}.${character.createdAt.year}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (provider.filter.sortOption == SortOption.dateAsc ||
                            provider.filter.sortOption == SortOption.dateDesc)
                          const SizedBox(width: 8),
                        if (provider.filter.sortOption == SortOption.dateAsc ||
                            provider.filter.sortOption == SortOption.dateDesc)
                          Icon(
                            provider.filter.sortOption == SortOption.dateAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _openCharacterDetails(character),
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Открыть',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterAvatar(Character character, ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getClassColor(character.characterClass.id).withAlpha(51),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getClassColor(character.characterClass.id),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          character.name[0].toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getClassColor(character.characterClass.id),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterStats(Character character, ThemeData theme) {
    final stats = character.stats;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatChip('❤️ ${character.maxHealth}', theme),
        _buildStatChip('⚔️ ${character.attack}', theme),
        _buildStatChip('🛡️ ${character.defense}', theme),
        _buildStatChip('🧠 ${stats['intelligence'] ?? 0}', theme),
      ],
    );
  }

  Widget _buildStatChip(String text, ThemeData theme) {
    return Chip(
      backgroundColor: theme.colorScheme.secondaryContainer,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Color _getClassColor(String classId) {
    const colors = {
      'warrior': Colors.red,
      'mage': Colors.blue,
      'rogue': Colors.green,
      'cleric': Colors.purple,
    };
    return colors[classId] ?? Colors.grey;
  }

  void _openCharacterDetails(Character character) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          character: character,
          isNewCharacter: false,
        ),
      ),
    );
  }

  void _showCharacterOptions(Character character, CharacterProvider provider) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Удалить'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(character, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Создать копию'),
                onTap: () {
                  Navigator.pop(context);
                  _duplicateCharacter(character, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Поделиться'),
                onTap: () {
                  Navigator.pop(context);
                  _shareCharacter(character);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(Character character, CharacterProvider provider) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить персонажа?'),
          content: Text(
            'Вы уверены, что хотите удалить персонажа "${character.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCharacter(character, provider);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCharacter(
      Character character, CharacterProvider provider) async {
    final success = await provider.deleteCharacter(character.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Персонаж удален'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _duplicateCharacter(
      Character character, CharacterProvider provider) async {
    final newCharacter = character.copyWith(
      id: generateCharacterId(),
      name: '${character.name} (копия)',
    );

    final characterWithNewDate = Character(
      id: newCharacter.id,
      name: newCharacter.name,
      characterClass: newCharacter.characterClass,
      level: newCharacter.level,
      stats: newCharacter.stats,
      skills: newCharacter.skills,
      background: newCharacter.background,
      appearance: newCharacter.appearance,
      createdAt: DateTime.now(),
    );

    final success = await provider.saveCharacter(characterWithNewDate);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Персонаж скопирован'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareCharacter(Character character) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция "Поделиться" доступна в деталях персонажа'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, CharacterProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          provider: provider,
          onApply: () {
            Navigator.pop(context);
          },
          onReset: () {
            provider.resetFilters();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showInfoDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Мои персонажи'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Тапните на персонажа для просмотра'),
              Text('• Удерживайте для дополнительных опций'),
              Text('• Используйте поиск и фильтры для навигации'),
              Text('• Персонажи сохраняются локально'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }
}
