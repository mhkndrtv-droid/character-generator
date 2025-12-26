import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'generator_screen.dart';
import 'characters_list_screen.dart';
import '../utils/image_paths.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Генератор персонажей'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: themeProvider.isDarkMode ? 'Светлая тема' : 'Темная тема',
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: themeProvider.isDarkMode
                    ? const Icon(Icons.light_mode, key: ValueKey('light'))
                    : const Icon(Icons.dark_mode, key: ValueKey('dark')),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
              ),
              onPressed: () {
                final newMode =
                    themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark;
                themeProvider.setThemeMode(newMode);

                final snackBar = SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        themeProvider.isDarkMode
                            ? 'Переключено на светлую тему'
                            : 'Переключено на темную тему',
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              tooltip: isDarkMode ? 'Светлая тема' : 'Темная тема',
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип или изображение
            Image.asset(
              ImagePaths.dice,
              width: 150,
              height: 150,
              color: Theme.of(context).colorScheme.primary,
              errorBuilder: (context, error, stackTrace) {
                // Если изображение не загрузилось
                return Icon(
                  Icons.casino,
                  size: 150,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),

            const SizedBox(height: 30),

            // Заголовок
            Text(
              'Создай своего героя!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 20),

            // Описание
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Создайте уникального персонажа для вашей настольной игры. '
                'Выберите класс, распределите характеристики и придумайте историю.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Кнопка создания персонажа
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneratorScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        ImagePaths.dice,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.casino,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Создать персонажа',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка "Мои персонажи"
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CharactersListScreen(),
                  ),
                );
              },
              child: const Text('Мои персонажи'),
            ),
          ],
        ),
      ),
    );
  }
}
