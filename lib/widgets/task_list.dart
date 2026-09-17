import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks.map((task) {
        return TaskCard(
          task: task,
          onTap: () => onTaskTap(task),
        );
      }).toList(),
    );
  }
}