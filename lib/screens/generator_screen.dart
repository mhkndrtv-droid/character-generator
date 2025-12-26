// lib/screens/generator_screen.dart
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/class_type.dart';
import '../widgets/class_card.dart';
import '../widgets/attribute_slider.dart';
import 'details_screen.dart';
import '../utils/image_paths.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final List<CharacterClass> classes = const [
    CharacterClass(
      id: 'warrior',
      name: 'Воин',
      description: 'Сильный и выносливый боец ближнего боя',
      imageUrl: ImagePaths.warrior,
      baseStats: {
        'strength': 15,
        'dexterity': 10,
        'constitution': 14,
        'intelligence': 8,
        'wisdom': 10,
        'charisma': 8,
      },
    ),
    CharacterClass(
      id: 'mage',
      name: 'Маг',
      description: 'Могущественный заклинатель, знающий тайны магии',
      imageUrl: ImagePaths.mage,
      baseStats: {
        'strength': 8,
        'dexterity': 12,
        'constitution': 10,
        'intelligence': 16,
        'wisdom': 14,
        'charisma': 10,
      },
    ),
    CharacterClass(
      id: 'rogue',
      name: 'Плут',
      description: 'Ловкий и хитрый, мастер скрытности и ловушек',
      imageUrl: ImagePaths.rogue,
      baseStats: {
        'strength': 10,
        'dexterity': 16,
        'constitution': 12,
        'intelligence': 12,
        'wisdom': 10,
        'charisma': 10,
      },
    ),
    CharacterClass(
      id: 'cleric',
      name: 'Жрец',
      description: 'Служитель божества, исцеляющий и защищающий',
      imageUrl: ImagePaths.cleric,
      baseStats: {
        'strength': 12,
        'dexterity': 10,
        'constitution': 12,
        'intelligence': 10,
        'wisdom': 16,
        'charisma': 12,
      },
    ),
  ];

  CharacterClass? selectedClass;
  final TextEditingController nameController = TextEditingController();
  int availablePoints = 20;
  Map<String, int> stats = {
    'strength': 10,
    'dexterity': 10,
    'constitution': 10,
    'intelligence': 10,
    'wisdom': 10,
    'charisma': 10,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedClass == null && classes.isNotEmpty) {
        setState(() {
          selectedClass = classes.first;
          stats = Map.from(selectedClass!.baseStats);
          _recalculatePoints();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final canCreate = _canCreateCharacter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание персонажа'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(
                'Очки: $availablePoints',
                style: TextStyle(
                  color: availablePoints >= 0
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : Colors.white,
                ),
              ),
              backgroundColor: availablePoints >= 0
                  ? Colors.green.withAlpha(30)
                  : Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле ввода имени
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Имя персонажа *',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(179),
                ),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                ),
                filled: true,
                errorText: nameController.text.isEmpty ? 'Введите имя' : null,
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // Выбор класса
            const Text(
              'Выберите класс:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (selectedClass == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Выберите класс персонажа *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Карточки классов
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return ClassCard(
                  characterClass: classes[index],
                  isSelected: selectedClass?.id == classes[index].id,
                  onTap: () {
                    setState(() {
                      selectedClass = classes[index];
                      if (selectedClass != null) {
                        stats = Map.from(selectedClass!.baseStats);
                        _recalculatePoints();
                      }
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Характеристики
            Row(
              children: [
                const Text(
                  'Характеристики:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                if (availablePoints < 0) ...[
                  Text(
                    'Использовано очков: ${20 - availablePoints}/20',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // Слайдеры характеристик
            ...stats.keys.map((statName) {
              return AttributeSlider(
                attributeName: _getRussianAttributeName(statName),
                value: stats[statName]!,
                minValue: 8,
                maxValue: 18,
                onChanged: (newValue) {
                  setState(() {
                    final oldValue = stats[statName]!;
                    final difference = newValue - oldValue;
                    stats[statName] = newValue;
                    availablePoints -= difference;
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            // Кнопка случайной генерации
            OutlinedButton.icon(
              onPressed: _generateRandomCharacter,
              icon: const Icon(Icons.casino),
              label: const Text('Случайная генерация'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            // Сообщения об ошибках
            if (!canCreate) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withAlpha(100)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Заполните обязательные поля',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Кнопка создания
            ElevatedButton(
              onPressed: canCreate ? _createCharacter : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                    canCreate ? theme.colorScheme.primary : Colors.grey,
                foregroundColor:
                    canCreate ? theme.colorScheme.onPrimary : Colors.grey[600],
              ),
              child: Text(
                'Создать персонажа',
                style: TextStyle(
                  fontSize: 18,
                  color: canCreate
                      ? theme.colorScheme.onPrimary
                      : Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Сообщение об успешной валидации
            if (canCreate) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withAlpha(100)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Персонаж готов к созданию!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

  void _recalculatePoints() {
    availablePoints = 20;
    for (final value in stats.values) {
      availablePoints -= (value - 10);
    }
  }

  void _generateRandomCharacter() {
    setState(() {
      final random = List.from(classes)..shuffle();
      selectedClass = random.first;
      stats = Map.from(selectedClass!.baseStats);

      const names = ['Артос', 'Лианна', 'Гром', 'Эльвира', 'Драко', 'Селене'];
      final shuffledNames = List.of(names)..shuffle();
      nameController.text = shuffledNames.first;

      _recalculatePoints();
    });
  }

  bool _canCreateCharacter() {
    if (nameController.text.trim().isEmpty) return false;
    if (selectedClass == null) return false;
    return true;
  }

  String _getValidationErrorMessage() {
    if (nameController.text.trim().isEmpty) {
      return 'Введите имя персонажа';
    }
    if (selectedClass == null) {
      return 'Выберите класс персонажа';
    }
    if (availablePoints < 0) {
      return 'Использовано больше очков, чем доступно. Персонаж может быть несбалансированным.';
    }
    return '';
  }

  void _createCharacter() {
    if (!_canCreateCharacter()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationErrorMessage()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (availablePoints < 0) {
      _showConfirmationDialog();
      return;
    }

    _createCharacterConfirmed();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Предупреждение'),
        content: Text(
          'Вы использовали ${20 - availablePoints} очков из 20 доступных.\n'
          'Персонаж может быть несбалансированным.\n\n'
          'Продолжить создание?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createCharacterConfirmed();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _createCharacterConfirmed() {
    final characterId = DateTime.now().millisecondsSinceEpoch.toString();

    final character = Character(
      id: characterId,
      name: nameController.text,
      characterClass: selectedClass!,
      level: 1,
      stats: Map.from(stats),
      skills: _generateSkills(),
      background: _generateBackground(),
      appearance: _generateAppearance(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          character: character,
          isNewCharacter: true,
        ),
      ),
    );
  }

  List<String> _generateSkills() {
    const allSkills = [
      'Атака',
      'Защита',
      'Скрытность',
      'Магия огня',
      'Исцеление',
      'Убеждение',
      'Взлом',
      'Выживание',
    ];

    final randomSkills = List<String>.from(allSkills)..shuffle();
    return randomSkills.take(3).toList();
  }

  String _generateBackground() {
    const backgrounds = [
      'Бывший солдат, ищущий искупления',
      'Ученик древнего ордена магов',
      'Сирота, выросший на улицах большого города',
      'Дворянин, бежавший от своей судьбы',
      'Искатель приключений, жаждущий славы',
      'Ученый, изучающий древние артефакты',
    ];

    final shuffled = List.of(backgrounds)..shuffle();
    return shuffled.first;
  }

  String _generateAppearance() {
    const appearances = [
      'Высокий и статный, с пронзительным взглядом',
      'Коренастый и сильный, со шрамами на лице',
      'Стройный и грациозный, с быстрыми движениями',
      'Загадочный, скрывающий лицо под капюшоном',
      'Яркий и харизматичный, привлекающий внимание',
      'Спокойный и мудрый, с седыми волосами',
    ];

    final shuffled = List.of(appearances)..shuffle();
    return shuffled.first;
  }
}
