import 'package:flutter/material.dart';
import 'package:quest_board/services/player_service.dart';
import '../models/quest_model.dart';
import '../widgets/player_stats.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';

class HomeScreen extends StatelessWidget { // Stateless widget: dadas no se guardan aqui esto es escencialmente una "imagen"
  final QuestService questService;
  final PlayerService playerService;

  const HomeScreen({
    super.key, // La "id" de esta classe
    required this.questService,
    required this.playerService
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: questService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey,
          appBar: AppBar(
            backgroundColor: Colors.grey,
            title: const Text("QuestBoard"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showQuestDialog(context);
            },
            child: const Icon(Icons.add),
          ),
          body: Row(
            children: [
              // Player information TODO:Get from hive
              Expanded(
                flex: 3,
                child: Builder(
                  builder: (context) {
                    final player = playerService.player;
                    return PlayerStats(
                      level: player.level,
                      experience: player.experience,
                      currentHealth: player.currentHealth,
                      maxHealth: player.maxHealth,
                    );
                  },
                ),
              ),

              // Quests
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QuestList(
                    quests: questService.quests,
                    onQuestTap: (quest) {
                      questService.updateQuest(
                        quest.id,
                        changeCompletion: true,
                      );
                    },
                    onQuestEdit: (quest) {
                      _showQuestDialog(
                        context,
                        quest: quest,
                      );
                    },
                    onQuestDelete: (quest) {
                      questService.removeQuest(quest);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuestDialog(BuildContext context, {QuestModel? quest}) {
    final titleController = TextEditingController(text: quest?.title ?? "",);
    final descriptionController = TextEditingController(text: quest?.description ?? "",);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(quest == null? "New Quest" : "Edit Quest"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
                maxLines: 3,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                if (quest == null) {
                  questService.addQuest(QuestModel(title: titleController.text,
                      description: descriptionController.text));
                }else {
                  questService.updateQuest(quest.id, newTitle: titleController.text, newDescription: descriptionController.text);
                }
                Navigator.pop(context);
              },
              child: Text(quest == null? "Create" : "Save"),
            ),
          ],
        );
      },
    );
  }

}