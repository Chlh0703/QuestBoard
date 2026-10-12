import 'package:flutter/material.dart';

import '../models/quest_model.dart';
import '../services/quest_service.dart';

void showArchivedQuestsDialog(
    BuildContext context, {
      required QuestService questService,
    }) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AnimatedBuilder(
        animation: questService,
        builder: (context, child) {
          final archivedQuests = questService.archivedQuests;

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
                          onPressed: () {
                            questService.restoreQuest(quest);
                          },
                        ),

                        IconButton(
                          tooltip: 'Delete permanently',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await questService.removeArchivedQuest(
                              quest,
                            );
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