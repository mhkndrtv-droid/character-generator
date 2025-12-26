import 'package:flutter/material.dart';
import '../models/class_type.dart';
import '../utils/image_paths.dart';

class ClassCard extends StatelessWidget {
  final CharacterClass characterClass;
  final bool isSelected;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.characterClass,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(25)
              : theme.colorScheme.surface,
          elevation: isSelected ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(51),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildClassImage(theme),
                const SizedBox(height: 10),
                Text(
                  characterClass.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  characterClass.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassImage(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Color(ImagePaths.getClassColor(characterClass.id)).withAlpha(51),
        shape: BoxShape.circle,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(76),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: _getClassImageWidget(),
    );
  }

  Widget _getClassImageWidget() {
    final imageUrl = characterClass.imageUrl;

    // Пытаемся загрузить изображение из assets
    if (imageUrl.isNotEmpty && imageUrl.startsWith('assets/')) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Если изображение не найдено, показываем запасной вариант
            return _buildFallbackImage();
          },
        ),
      );
    } else {
      // Если нет пути к изображению, показываем запасной вариант
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              Color(ImagePaths.getClassColor(characterClass.id)).withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            characterClass.name.isNotEmpty
                ? characterClass.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(ImagePaths.getClassColor(characterClass.id)),
            ),
          ),
        ),
      ),
    );
  }
}
