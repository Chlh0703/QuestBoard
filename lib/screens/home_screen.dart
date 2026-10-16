import 'package:flutter/material.dart';
import 'package:quest_board/services/player_service.dart';

import '../dialogs/achievements_dialog.dart';
import '../services/player_achievements.dart';
import '../widgets/player_stats.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';
import '../dialogs/statistics_dialog.dart';
import '../dialogs/quest_dialog.dart';
import '../dialogs/archived_quests_dialog.dart';

class HomeScreen extends StatelessWidget {
  final QuestService questService;
  final PlayerService playerService;
  final PlayerAchievements playerAchievements;

  const HomeScreen({
    super.key,
    required this.questService,
    required this.playerService,
    required this.playerAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: questService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.amberAccent,

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showQuestDialog(
                context,
                questService: questService,

              );
            },
            child: const Icon(Icons.add),
          ),

          body: Row(
            children: [
              // Player
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: PlayerStats(
                        player: playerService.player,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Statistics
                          IconButton(
                            tooltip: 'Statistics',
                            onPressed: () {
                              showStatisticsDialog(context, playerService: playerService,);
                            },
                            icon: const Icon(Icons.bar_chart),
                            iconSize: 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              fixedSize: const Size(56, 56),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Achievements
                          IconButton(
                            tooltip: 'Achievements',
                            onPressed: () {
                              showAchievementsDialog(context, playerAchievements: playerAchievements,);
                            },
                            icon: const Icon(Icons.emoji_events_outlined),
                            iconSize: 28,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.amber.shade800,
                              fixedSize: const Size(56, 56),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quests
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Título y botón de misiones archivadas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'QUESTS',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 12),

                          IconButton(
                            tooltip: 'Archived quests',
                            icon: const Icon(Icons.archive_outlined),
                            onPressed: () {
                              showArchivedQuestsDialog(context, questService: questService);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: QuestList(
                          quests: questService.quests,

                          // Pause / resume
                          onTogglePause: (quest) {
                            questService.updateQuest(
                              quest.id,
                              togglePause: true,
                            );
                          },

                          // Edit
                          onQuestEdit: (quest) {
                            showQuestDialog(
                              context,
                              questService: questService,
                              quest: quest,
                            );
                          },

                          // Archive Quest
                          onQuestArchive: (quest) {
                            questService.archiveQuest(quest);
                          },
                          onQuestDelete: (quest) {
                             questService.removeArchivedQuest(quest);
                            },
                          // Change Completion On Task
                          onTaskTap: (quest, task) {
                            questService.updateQuest(quest.id, taskId: task.id, taskTapped: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}