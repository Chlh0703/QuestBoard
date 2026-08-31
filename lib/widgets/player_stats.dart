import 'package:flutter/material.dart';

class PlayerStats extends StatelessWidget {
  final int level;
  final int experience;
  final int currentHealth;
  final int maxHealth;

  const PlayerStats({
    super.key,
    required this.level,
    required this.experience,
    required this.currentHealth,
    required this.maxHealth,
  });

  static int experienceRequiredForNextLevel(int level) {
    return 100 + (level - 1) * 50;
  }

  @override
  Widget build(BuildContext context) {
    final maxExperience =
    experienceRequiredForNextLevel(level);

    final expProgress = maxExperience > 0
        ? (experience / maxExperience).clamp(0.0, 1.0)
        : 0.0;

    final healthProgress = maxHealth > 0
        ? (currentHealth / maxHealth).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            const CircleAvatar(
              radius: 70,
              child: Icon(
                Icons.person,
                size: 100,
              ),
            ),

            const SizedBox(height: 20),

            // Level
            Row(
              children: [
                const Text(
                  'LV',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$level',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // EXP
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'EXP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            LinearProgressIndicator(
              value: expProgress,
              minHeight: 10,
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$experience / $maxExperience',
              ),
            ),

            const SizedBox(height: 25),

            // HP
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'HP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            LinearProgressIndicator(
              value: healthProgress,
              minHeight: 10,
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$currentHealth / $maxHealth',
              ),
            ),
          ],
        ),
      ),
    );
  }
}