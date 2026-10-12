import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quest_board/models/player_statistics.dart';

class StatisticsDialog extends StatelessWidget {
  final PlayerStatistics statistics;

  const StatisticsDialog({
    super.key,
    required this.statistics,
  });

  static const List<String> questTypeNames = [
    'Principal',
    'Secondary',
    'Repetitive',
  ];

  static const List<Color> questTypeColors = [
    Colors.amber,
    Colors.blue,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final values = statistics.completedQuestsByType;

    final total = values.fold<int>(
      0,
          (sum, value) => sum + value,
    );

    return AlertDialog(
      title: const Text('Player Statistics'),

      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total completed quests: $total'),

            const SizedBox(height: 24),

            if (total == 0)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Complete your first quest to see your statistics!',
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 35,
                    sections: List.generate(
                      values.length,
                          (index) {
                        final value = values[index];
                        final percentage = value / total * 100;

                        return PieChartSectionData(
                          value: value.toDouble(),
                          color: questTypeColors[index],
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 85,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            ...List.generate(
              values.length,
                  (index) {
                final value = values[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: questTypeColors[index],
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(questTypeNames[index]),
                      ),

                      Text('$value'),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quests created'),
                Text('${statistics.questsCreated}'),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total experience earned'),
                Text('${statistics.totalExperienceEarned} XP'),
              ],
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
}