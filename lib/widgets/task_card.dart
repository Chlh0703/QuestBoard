import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_board/services/datetime_service.dart';

import '../models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                widget.task.completed
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: widget.task.completed
                    ? Colors.green
                    : Colors.white,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  widget.task.title,
                  style: TextStyle(
                    color: widget.task.completed
                        ? Colors.white54
                        : Colors.white,
                    decoration: widget.task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              if (widget.task.dueDate != null)
                Text(
                  DateTimeService.formatRemainingTime(widget.task.dueDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.task.completed
                        ? Colors.green
                        : Colors.white,
                  ),

                ),
            ],
          ),
        ),
      ),
    );
  }
}