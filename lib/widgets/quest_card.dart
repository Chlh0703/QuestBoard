import 'package:flutter/material.dart';
import 'package:quest_board/widgets/task_list.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';

class QuestCard extends StatelessWidget { // La gracia de stateless esque aqui no se guardan datos, si se guardaran seria stateful
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onTogglePause;
  final Function(TaskModel) onTaskTap;

  final QuestModel quest;
  const QuestCard({
    super.key, // Todos tienen una key, eso es para identificar, de alguna forma es parecido a una biblioteca
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
      padding: const EdgeInsets.only(bottom: 8),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================
            // QUEST
            // =====================

            Row(
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    color: quest.completed
                        ? Colors.green
                        : Colors.white,
                    decoration: quest.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                const Spacer(),

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

            const SizedBox(height: 10),

            // =====================
            // TASKS
            // =====================

            TaskList(
              tasks: quest.tasks,
              onTaskTap: onTaskTap,
            ),

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

            // =====================
            // ARCHIVE
            // =====================

            if (quest.completed)
              ElevatedButton(
                onPressed: onArchive,
                child: const Text('Archive'),
              ),
          ],
        ),
      ),
    );
  }
}