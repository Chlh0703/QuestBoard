import 'package:flutter/material.dart';
import 'package:quest_board/widgets/task_list.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';

class QuestCard extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onTogglePause;
  final Function(TaskModel) onTaskTap;

  final QuestModel quest;

  const QuestCard({
    super.key,
    required this.quest,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    required this.onTogglePause,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================
            // QUEST HEADER
            // =====================

            Row(
              children: [

                // Quest title
                Expanded(
                  child: Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: quest.completed
                          ? Colors.green
                          : Colors.white,
                      decoration: quest.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Play / Pause
                IconButton(
                  onPressed: onTogglePause,
                  icon: Icon(
                    quest.paused
                        ? Icons.play_arrow
                        : Icons.pause,
                  ),
                  color: quest.paused
                      ? Colors.green
                      : Colors.orange,
                  tooltip: quest.paused
                      ? 'Resume'
                      : 'Pause',
                ),

                // Edit
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),

                // Delete
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // =====================
            // TASKS
            // =====================

            TaskList(
              tasks: quest.tasks,
              onTaskTap: onTaskTap,
            ),

            const SizedBox(height: 10),

            // =====================
            // REWARD
            // =====================

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${quest.experienceReward} EXP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: quest.completed
                        ? Colors.green
                        : Colors.white,
                    decoration: quest.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),

            // =====================
            // ARCHIVE
            // =====================

            if (quest.completed) ...[
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: onArchive,
                child: const Text('Archive'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}