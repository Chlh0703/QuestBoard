import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';

class HomeScreen extends StatelessWidget { // Stateless widget: dadas no se guardan aqui esto es escencialmente una "imagen"
  final QuestService questService;

  const HomeScreen({
    super.key, // La "id" de esta classe
    required this.questService,
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
              _showAddQuestDialog(context);
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: QuestList(
              quests: questService.quests,
              onQuestTap: (quest) {
                questService.updateQuest(quest, changeCompletion: true);
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddQuestDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Quest"),

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
                questService.addQuest(Quest(title: titleController.text, description: descriptionController.text));
                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

}