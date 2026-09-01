import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_board/services/player_service.dart';

import '../models/quest_model.dart';
import '../widgets/player_stats.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';

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
          backgroundColor: Colors.grey,

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showQuestDialog(context);
            },
            child: const Icon(Icons.add),
          ),

          body: Row(
            children: [
              // Player
              Expanded(
                flex: 3,
                child: PlayerStats(
                  player: playerService.player,
                ),
              ),

              // Quests
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'QUESTS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: QuestList(
                          quests: questService.quests,

                          // Complete / uncomplete
                          onToggleCompletion: (quest) {
                            questService.updateQuest(
                              quest.id,
                              changeCompletion: true,
                            );
                          },

                          // Pause / resume
                          onTogglePause: (quest) {
                            questService.updateQuest(
                              quest.id,
                              togglePause: true,
                            );
                          },

                          // Edit
                          onQuestEdit: (quest) {
                            _showQuestDialog(
                              context,
                              quest: quest,
                            );
                          },

                          // Delete
                          onQuestDelete: (quest) {
                            questService.removeQuest(quest);
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

  void _showQuestDialog(
      BuildContext context, {
        QuestModel? quest,
      }) {
    final titleController = TextEditingController(
      text: quest?.title ?? "",
    );

    final experienceController = TextEditingController(
      text: quest?.experienceReward.toString() ?? "",
    );

    // If editing, use the quest's current classification.
    // If creating, default to Principal.
    int classification = quest?.classification ?? 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                quest == null ? "New Quest" : "Edit Quest",
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Classification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: 'Principal',
                        child: ChoiceChip(
                          label: const Text('P'),
                          selected: classification == 1,
                          onSelected: (_) {
                            setState(() {
                              classification = 1;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Tooltip(
                        message: 'Secondary',
                        child: ChoiceChip(
                          label: const Text('S'),
                          selected: classification == 2,
                          onSelected: (_) {
                            setState(() {
                              classification = 2;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Tooltip(
                        message: 'Repetitive',
                        child: ChoiceChip(
                          label: const Text('R'),
                          selected: classification == 3,
                          onSelected: (_) {
                            setState(() {
                              classification = 3;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Experience
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: "Experience",
                      hintText: "1 - 1000",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),

              actions: [
                // Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                // Create / Save
                ElevatedButton(
                  onPressed: () {
                    final experience =
                        int.tryParse(experienceController.text) ?? 0;

                    // Validate experience
                    if (experience < 1 || experience > 1000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Experience must be between 1 and 1000.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Validate title
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Create
                    if (quest == null) {
                      questService.addQuest(
                        QuestModel(
                          title: titleController.text.trim(),
                          experienceReward: experience,
                          classification: classification,
                        ),
                      );
                    }

                    // Edit
                    else {
                      questService.updateQuest(
                        quest.id,
                        newTitle: titleController.text.trim(),
                        newExpReward: experience,
                        newClassification: classification,
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    quest == null ? "Create" : "Save",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}