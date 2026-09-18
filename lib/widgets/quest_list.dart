import 'package:flutter/material.dart';
import '../models/quest_model.dart';
import '../models/task_model.dart';
import 'quest_card.dart';

class QuestList extends StatelessWidget {
  final List<QuestModel> quests;

  final Function(QuestModel) onTogglePause;
  final Function(QuestModel) onQuestEdit;
  final Function(QuestModel) onQuestDelete;
  final Function(QuestModel, TaskModel) onTaskTap;

  const QuestList({
    super.key,
    required this.quests,
    required this.onTogglePause,
    required this.onQuestEdit,
    required this.onQuestDelete,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final mainQuests = quests
        .where((quest) =>
    quest.classification == 1)
        .toList();

    final secondaryQuests = quests
        .where((quest) =>
    quest.classification == 2)
        .toList();

    final repetitiveQuests = quests
        .where((quest) =>
    quest.classification == 3)
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildSection(
            'MAIN',
            mainQuests,
          ),
        ),

        const SizedBox(width: 24),

        Expanded(
          child: _buildSection(
            'SECONDARY',
            secondaryQuests,
          ),
        ),

        const SizedBox(width: 24),

        Expanded(
          child: _buildSection(
            'REPETITIVE',
            repetitiveQuests,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title,
      List<QuestModel> quests,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final quest = quests[index];

              return QuestCard(
                quest: quest,
                onTogglePause: () {
                  onTogglePause(quest);
                  },
                onEdit: () {
                  onQuestEdit(quest);
                  },
                onDelete: () {
                  onQuestDelete(quest);
                  },
                onArchive: () {
                  print("Archiving");
                  }, // TODO
                onTaskTap: (task) {
                  onTaskTap(quest, task);
                  },
              );
            },
          ),
        ),
      ],
    );
  }
}