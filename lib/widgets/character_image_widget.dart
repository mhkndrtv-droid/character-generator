import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterImageWidget extends StatelessWidget {
  final Character character;

  const CharacterImageWidget({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.blueAccent
                ], // Используем константные цвета
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              character.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Основная информация
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('Уровень ${character.level}', Colors.orange),
              const SizedBox(width: 10),
              _buildInfoChip(character.characterClass.name, Colors.blue),
            ],
          ),

          const SizedBox(height: 30),

          // Статистика
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStatCard(
                  'Здоровье', character.maxHealth.toString(), Icons.favorite),
              _buildStatCard('Атака', character.attack.toString(),
                  Icons.sports_martial_arts),
              _buildStatCard(
                  'Защита', character.defense.toString(), Icons.shield),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    // Используем константные значения для градиента
    const gradientColors = [Colors.lightBlue, Colors.white];
    const gradient = LinearGradient(colors: gradientColors);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(76, 128, 128, 128),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blue[800]),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
