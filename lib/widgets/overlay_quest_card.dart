import 'package:flutter/material.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../widgets/task_list.dart';

class OverlayQuestCard extends StatelessWidget {
  final Function(QuestModel, TaskModel) onTaskTap;
  final QuestModel quest;

  const OverlayQuestCard({
    super.key,
    required this.quest,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // =====================
          // QUEST
          // =====================

          Text(
            quest.completed
                ? "■ ${quest.title}"
                : "□ ${quest.title}",
            style: TextStyle(
              color: quest.completed
                  ? Colors.green
                  : Colors.white,
              decoration: quest.completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),

          const SizedBox(height: 4),

          // =====================
          // TASKS
          // =====================

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TaskList(
              tasks: quest.tasks,
              onTaskTap: (task) {onTaskTap(quest, task);},
            ),
          ),

          const SizedBox(height: 4),

          // =====================
          // REWARD
          // =====================

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "REWARD: ${quest.experienceReward} EXP",
              style: TextStyle(
                color: quest.completed
                    ? Colors.green
                    : Colors.white,
                decoration: quest.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}