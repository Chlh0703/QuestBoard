import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_board/services/player_service.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../widgets/player_stats.dart';
import '../widgets/quest_list.dart';
import '../services/quest_service.dart';

class HomeScreen extends StatelessWidget {
  final QuestService questService;
  final PlayerService playerService;

  const HomeScreen({
    super.key,
    required this.questService,
    required this.playerService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: questService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.amberAccent,

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showQuestDialog(context);
            },
            child: const Icon(Icons.add),
          ),

          body: Row(
            children: [
              // Player
              Expanded(
                flex: 2,
                child: PlayerStats(
                  player: playerService.player,
                ),
              ),

              // Quests
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'QUESTS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: QuestList(
                          quests: questService.quests,

                          // Pause / resume
                          onTogglePause: (quest) {
                            questService.updateQuest(
                              quest.id,
                              togglePause: true,
                            );
                          },

                          // Edit
                          onQuestEdit: (quest) {
                            _showQuestDialog(
                              context,
                              quest: quest,
                            );
                          },

                          // Delete
                          onQuestDelete: (quest) {
                            questService.removeQuest(quest);
                          },

                          // Change Completion On Task
                          onTaskTap: (quest, task) {
                            questService.updateQuest(quest.id, taskId: task.id, changeTaskCompletion: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuestDialog(
      BuildContext context, {
        QuestModel? quest,
      }) {
    final titleController = TextEditingController(
      text: quest?.title ?? "",
    );

    final experienceController = TextEditingController(
      text: quest?.experienceReward.toString() ?? "",
    );

    // If editing, use the quest's current classification.
    // If creating, default to Principal.
    int classification = quest?.classification ?? 1;

    // Copy the current tasks so we don't modify the original
    // Quest until the user presses Save.
    List<TaskModel> tasks = quest?.tasks
        .map(
          (task) => TaskModel(
        id: task.id,
        title: task.title,
        completed: task.completed,
      ),
    )
        .toList() ??
        [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                quest == null ? "New Quest" : "Edit Quest",
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
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
                        "Tasks",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Current tasks
                    if (tasks.isNotEmpty)
                      ...tasks.map(
                            (task) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,

                            title: Text(task.title),

                            onTap: () {
                              _showTaskDialog(
                                context,
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
                        _showTaskDialog(
                          context,
                          onTaskCreated: (task) {
                            setState(() {
                              tasks.add(task);
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Task"),
                    ),

                    const SizedBox(height: 20),

                    // Experience
                    TextField(
                      controller: experienceController,
                      decoration: const InputDecoration(
                        labelText: "Experience",
                        hintText: "1 - 1000",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),


                  ],
                ),
              ),

              actions: [

                // Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                // Create / Save
                ElevatedButton(
                  onPressed: () {
                    final experience =
                        int.tryParse(
                          experienceController.text,
                        ) ??
                            0;

                    // Validate experience
                    if (experience < 1 ||
                        experience > 1000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Experience must be between 1 and 1000.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Validate title
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Create
                    if (quest == null) {
                      questService.addQuest(
                        QuestModel(
                          title: titleController.text.trim(),
                          experienceReward: experience,
                          classification: classification,
                          tasks: tasks,
                        ),
                      );
                    }

                    // Edit
                    else {
                      questService.updateQuest(
                        quest.id,
                        newTitle: titleController.text.trim(),
                        newExpReward: experience,
                        newClassification: classification,
                        newTasks: tasks,
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    quest == null ? "Create" : "Save",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskDialog(
      BuildContext context, {
        TaskModel? task,
        Function(TaskModel)? onTaskCreated,
        Function(TaskModel)? onTaskEdited,
      }) {
    final titleController = TextEditingController(
      text: task?.title ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            task == null ? "New Task" : "Edit Task",
          ),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  return;
                }

                if (task == null) {
                  // CREAR
                  final newTask = TaskModel(
                    title: title,
                  );

                  onTaskCreated?.call(newTask);
                } else {
                  // EDITAR
                  task.setTitle(title);

                  onTaskEdited?.call(task);
                }

                Navigator.pop(context);
              },
              child: Text(
                task == null ? "Create" : "Save",
              ),
            ),
          ],
        );
      },
    );
  }
}