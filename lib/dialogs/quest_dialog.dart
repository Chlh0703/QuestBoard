import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_board/controllers/quest_controller.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../services/datetime_service.dart';
import '../services/quest_service.dart';

import 'due_date_dialog.dart';
import 'task_dialog.dart';

void showQuestDialog(
    BuildContext context, {
      required QuestController questController,
      QuestModel? quest,
    }) {
  final titleController = TextEditingController(
    text: quest?.title ?? '',
  );

  final experienceController = TextEditingController(
    text: quest?.experienceReward.toString() ?? '',
  );

  final repeatIntervalController = TextEditingController(
    text: quest != null &&
        quest.startDate != null &&
        quest.dueDate != null
        ? quest.dueDate!
        .difference(quest.startDate!)
        .inDays
        .toString()
        : '',
  );

  int classification = quest?.classification ?? 1;

  DateTime? startDate =
      quest?.startDate ?? DateTimeService.startOfDay(DateTime.now());

  DateTime? dueDate = quest?.dueDate;

  DateTime? repeatEnd = quest?.repeatEnd;

  final List<TaskModel> tasks = quest?.tasks
      .map(
        (task) => TaskModel(
      id: task.id,
      title: task.title,
      completed: task.completed,
      dueDate: task.dueDate,
      currentCount: task.currentCount,
      targetCount: task.targetCount,
      description: task.description,
    ),
  )
      .toList() ??
      [];

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              quest == null ? 'New Quest' : 'Edit Quest',
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Classification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: 'Principal',
                        child: ChoiceChip(
                          label: const Text('P'),
                          selected: classification == 1,
                          onSelected: (_) {
                            setState(() {
                              classification = 1;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Tooltip(
                        message: 'Secondary',
                        child: ChoiceChip(
                          label: const Text('S'),
                          selected: classification == 2,
                          onSelected: (_) {
                            setState(() {
                              classification = 2;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Tooltip(
                        message: 'Repetitive',
                        child: ChoiceChip(
                          label: const Text('R'),
                          selected: classification == 3,
                          onSelected: (_) {
                            setState(() {
                              classification = 3;
                              dueDate = null;

                              for (final task in tasks) {
                                task.setDueDate(null);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tasks
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (tasks.isNotEmpty)
                    ...tasks.map(
                          (task) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title),

                              if (task.dueDate != null)
                                Text(
                                  DateTimeService.formatDateTime(
                                    task.dueDate!,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),

                          onTap: () {
                            showTaskDialog(
                              context,
                              questClassification: classification,
                              questDueDate: dueDate,
                              task: task,
                              onTaskEdited: (_) {
                                setState(() {});
                              },
                            );
                          },

                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                tasks.remove(task);
                              });
                            },
                          ),
                        );
                      },
                    ),

                  // Add task
                  TextButton.icon(
                    onPressed: () {
                      showTaskDialog(
                        context,
                        questClassification: classification,
                        questDueDate: dueDate,
                        onTaskCreated: (task) {
                          setState(() {
                            tasks.add(task);
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  ),

                  const SizedBox(height: 20),

                  // Experience
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience',
                      hintText: '1 - 1000',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Repetitive quest configuration
                  if (classification == 3) ...[
                    Row(
                      children: [
                        const Text('Repeat every:'),

                        const SizedBox(width: 12),

                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: repeatIntervalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final days = int.tryParse(value);

                              if (days != null && days > 0) {
                                setState(() {
                                  dueDate = startDate.add(
                                    Duration(days: days),
                                  );
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Text('Days'),
                      ],
                    ),

                    if (repeatIntervalController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Text('Until:'),

                          const SizedBox(width: 12),

                          TextButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: repeatEnd ?? startDate,
                                firstDate: startDate,
                                lastDate: DateTime(2100),
                              );

                              if (selectedDate != null) {
                                setState(() {
                                  repeatEnd = selectedDate;
                                });
                              }
                            },
                            child: Text(
                              repeatEnd != null
                                  ? DateTimeService.formatDateTime(
                                repeatEnd!,
                              )
                                  : 'Select date',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
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
                  final experience =
                      int.tryParse(experienceController.text) ?? 0;

                  if (experience < 1 || experience > 1000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Experience must be between 1 and 1000.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title cannot be empty.'),
                      ),
                    );
                    return;
                  }

                  // Create quest
                  if (quest == null) {
                    questController.addQuest(
                      QuestModel(
                        title: titleController.text.trim(),
                        experienceReward: experience,
                        classification: classification,
                        tasks: tasks,
                        dueDate: dueDate,
                        startDate: startDate,
                      ),
                    );
                  } else {
                    // Edit quest
                    questController.updateQuest(
                      quest.id,
                      newTitle: titleController.text.trim(),
                      newExpReward: experience,
                      newClassification: classification,
                      newTasks: tasks,
                      newDueDate: dueDate,
                    );
                  }

                  Navigator.pop(dialogContext);
                },
                child: Text(
                  quest == null ? 'Create' : 'Save',
                ),
              ),
            ],
          );
        },
      );
    },
  );
}