import 'package:flutter/material.dart';
import 'package:quest_board/services/player_service.dart';

import '../dialogs/due_date_dialog.dart';
import '../models/quest_model.dart';
import '../widgets/player_stats.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';
import '../dialogs/statistics_dialog.dart';
import '../dialogs/quest_dialog.dart';
import '../dialogs/archived_quests_dialog.dart';
import '../dialogs/statistics_dialog.dart';

class HomeScreen extends StatelessWidget {
  final QuestService questService;
  final PlayerService playerService;

  const HomeScreen({
    super.key,
    required this.questService,
    required this.playerService,
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
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showStatisticsDialog(context);
                          },
                          icon: const Icon(Icons.pie_chart_outline),
                          label: const Text('Statistics'),
                        ),
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
                            print('3. HomeScreen recibió la petición de archivar: ${quest.title}');

                            questService.archiveQuest(quest);
                          },
                          onQuestDelete: (quest) {
                            // questService.removeQuest(quest); TODO check later
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

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: playerService,
          builder: (context, child) {
            return StatisticsDialog(
              statistics: playerService.statistics,
            );
          },
        );
      },
    );
  }
}