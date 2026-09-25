import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quest_board/services/datetime_service.dart';
import 'package:quest_board/widgets/task_list.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';

class QuestCard extends StatefulWidget {
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
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Actualizamos el contador cada segundo.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (widget.quest.dueDate != null && mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
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
                    widget.quest.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.quest.completed
                          ? Colors.green
                          : Colors.white,
                      decoration: widget.quest.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Play / Pause
                IconButton(
                  onPressed: widget.onTogglePause,
                  icon: Icon(
                    widget.quest.paused
                        ? Icons.play_arrow
                        : Icons.pause,
                  ),
                  color: widget.quest.paused
                      ? Colors.green
                      : Colors.orange,
                  tooltip: widget.quest.paused
                      ? 'Resume'
                      : 'Pause',
                ),

                // Edit
                IconButton(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit),
                ),

                // Delete
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),

            // =====================
            // DEADLINE
            // =====================

            if (widget.quest.dueDate != null)
              Text(
                DateTimeService.formatRemainingTime(widget.quest.dueDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.quest.completed
                      ? Colors.green
                      : Colors.white,
                ),
              ),

            const SizedBox(height: 8),

            // =====================
            // TASKS
            // =====================

            TaskList(
              tasks: widget.quest.tasks,
              onTaskTap: widget.onTaskTap,
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
                  '${widget.quest.experienceReward} EXP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.quest.completed
                        ? Colors.green
                        : Colors.white,
                    decoration: widget.quest.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),

            // =====================
            // ARCHIVE
            // =====================

            if (widget.quest.completed) ...[
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: widget.onArchive,
                child: const Text('Archive'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}