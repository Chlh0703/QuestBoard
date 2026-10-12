import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/datetime_service.dart';
import 'due_date_dialog.dart';

void showTaskDialog(
    BuildContext context, {
      required int questClassification,
      DateTime? questDueDate,
      TaskModel? task,
      Function(TaskModel)? onTaskCreated,
      Function(TaskModel)? onTaskEdited,
    }) {
  final titleController = TextEditingController(
    text: task?.title ?? '',
  );

  final currentCountController = TextEditingController(
    text: task?.currentCount?.toString() ?? '',
  );

  final targetCountController = TextEditingController(
    text: task?.targetCount?.toString() ?? '',
  );

  final descriptionController = TextEditingController(
    text: task?.description ?? '',
  );

  DateTime? dueDate = task?.dueDate;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              task == null ? 'New Task' : 'Edit Task',
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (task != null) ...[
                    TextField(
                      controller: currentCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Count',
                        hintText: 'Example: 23',
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: targetCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Count',
                      hintText: 'Example: 50',
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (questClassification != 3) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final selectedDate = await selectDueDate(
                            context,
                            dueDate,
                            maximumDueDate: questDueDate,
                          );

                          setState(() {
                            dueDate = selectedDate;
                          });
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          dueDate == null
                              ? 'No deadline'
                              : DateTimeService.formatDateTime(dueDate!),
                        ),
                      ),
                    ),

                    if (questDueDate != null) ...[
                      const SizedBox(height: 8),

                      Text(
                        'Quest deadline: '
                            '${DateTimeService.formatDateTime(questDueDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    TextField(
                      controller: descriptionController,
                      minLines: 5,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        hintText: 'Write a description...',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title cannot be empty.'),
                      ),
                    );
                    return;
                  }

                  int? currentCount =
                  int.tryParse(currentCountController.text.trim());

                  final int? targetCount =
                  int.tryParse(targetCountController.text.trim());

                  // Si ambos campos están vacíos, no hay contador.
                  if (currentCountController.text.trim().isEmpty &&
                      targetCountController.text.trim().isEmpty) {
                    currentCount = null;
                  } else {
                    // Si se configura un objetivo, ambos campos deben ser válidos.
                    if (targetCount == null || currentCount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter both Current Count and Target Count.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (currentCount < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current Count cannot be negative.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (targetCount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Target Count must be greater than 0.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (currentCount > targetCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current Count cannot exceed Target Count.',
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  if (questDueDate != null &&
                      dueDate != null &&
                      dueDate!.isAfter(questDueDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Task deadline cannot be later than the quest deadline.',
                        ),
                      ),
                    );
                    return;
                  }

                  final description = descriptionController.text.trim();

                  if (task == null) {
                    final newTask = TaskModel(
                      title: title,
                      dueDate: dueDate,
                      currentCount: currentCount,
                      targetCount: targetCount,
                      description: description,
                    );

                    onTaskCreated?.call(newTask);
                  } else {
                    task.setTitle(title);
                    task.setDueDate(dueDate);
                    task.setCurrentCount(currentCount);
                    task.setTargetCount(targetCount);
                    task.setDescription(description);

                    onTaskEdited?.call(task);
                  }

                  Navigator.pop(dialogContext);
                },
                child: Text(
                  task == null ? 'Create' : 'Save',
                ),
              ),
            ],
          );
        },
      );
    },
  );
}