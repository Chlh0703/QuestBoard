import 'package:flutter/material.dart';

import '../models/achievement_model.dart';
import '../services/player_achievements.dart';

void showAchievementsDialog(
    BuildContext context, {
      required PlayerAchievements playerAchievements,
    }) {
  showDialog(
    context: context,
    builder: (context) {
      return AnimatedBuilder(
        animation: playerAchievements,
        builder: (context, child) {
          return AchievementsDialog(
            playerAchievements: playerAchievements,
          );
        },
      );
    },
  );
}

class AchievementsDialog extends StatelessWidget {
  final PlayerAchievements playerAchievements;

  const AchievementsDialog({
    super.key,
    required this.playerAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = playerAchievements.achievements;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.emoji_events_outlined),
          SizedBox(width: 12),
          Text('Achievements'),
        ],
      ),

      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progreso global.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Unlocked achievements'),

                Text(
                  '${playerAchievements.unlockedCount}'
                      ' / ${playerAchievements.totalAchievements}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: playerAchievements.completionPercentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 20),

            // Lista de achievements.
            if (achievements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No achievements available yet.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: achievements.length,
                  separatorBuilder: (context, index) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];

                    return _buildAchievementTile(achievement);
                  },
                ),
              ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(AchievementModel achievement) {
    final unlocked = achievement.unlocked;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),

      leading: CircleAvatar(
        backgroundColor: unlocked
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.15),
        child: Icon(
          unlocked
              ? Icons.emoji_events
              : Icons.lock_outline,
          color: unlocked ? Colors.amber.shade800 : Colors.grey,
        ),
      ),

      title: Text(
        achievement.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: unlocked ? null : Colors.grey,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          Text(achievement.description),

          if (unlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 4),

            Text(
              'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),

      trailing: unlocked
          ? const Icon(
        Icons.check_circle,
        color: Colors.green,
      )
          : const Icon(
        Icons.lock_outline,
        color: Colors.grey,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}