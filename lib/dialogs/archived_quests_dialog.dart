import 'package:flutter/material.dart';
import 'package:quest_board/controllers/quest_controller.dart';

void showArchivedQuestsDialog(
    BuildContext context, {
      required QuestController questController,
    }) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AnimatedBuilder(
        animation: questController.listenable,
        builder: (context, child) {
          final archivedQuests = questController.archivedQuests;

          return AlertDialog(
            title: const Text('Archived Quests'),

            content: SizedBox(
              width: 400,
              child: archivedQuests.isEmpty
                  ? const Center(
                child: Text('No archived quests.'),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: archivedQuests.length,
                itemBuilder: (context, index) {
                  final quest = archivedQuests[index];

                  return ListTile(
                    leading: const Icon(Icons.archive),

                    title: Text(quest.title),

                    subtitle: Text(
                      switch (quest.classification) {
                        1 => 'Principal',
                        2 => 'Secondary',
                        3 => 'Repetitive',
                        _ => 'Unknown',
                      },
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Restore Quest',
                          icon: const Icon(
                            Icons.unarchive_outlined,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await questController.restoreQuest(quest);
                          },
                        ),

                        IconButton(
                          tooltip: 'Delete permanently',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await questController.removeArchivedQuest(quest);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}