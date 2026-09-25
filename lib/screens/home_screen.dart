import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_board/services/datetime_service.dart';
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
                            questService.updateQuest(quest.id, taskId: task.id, taskTapped: true);
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

    // Current quest deadline.
    DateTime? dueDate = quest?.dueDate;

    // Copy the current tasks so we don't modify the original
    // Quest until the user presses Save.
    List<TaskModel> tasks = quest?.tasks
        .map(
          (task) => TaskModel(
            id: task.id,
            title: task.title,
            completed: task.completed,
            dueDate: task.dueDate,
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Current tasks
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
                                    DateTimeService.formatDateTime(task.dueDate!),

                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),

                            onTap: () {
                              _showTaskDialog(
                                context,
                                questDueDate: quest?.dueDate,
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
                          questDueDate: quest?.dueDate,
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

                    const SizedBox(height: 20),

                    // Due Date

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Due Date",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final selectedDate = await _selectDueDate(
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
                              ? "No deadline"
                              : DateTimeService.formatDateTime(dueDate!),
                        ),
                      ),
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
                          dueDate: dueDate,
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
                        newDueDate: dueDate,
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

  Future<DateTime?> _selectDueDate(
      BuildContext context,
      DateTime? currentDueDate, {
        DateTime? maximumDueDate,
      }) async {
    final now = DateTime.now();

    final option = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Due Date'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'today');
              },
              child: const Text('Today'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'tomorrow');
              },
              child: const Text('Tomorrow'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'nextWeek');
              },
              child: const Text('Next week'),
            ),
            if (maximumDueDate != null)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'maxLength');
                },
                child: const Text('Max Length'),
              ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'custom');
              },
              child: const Text('Custom...'),
            ),
            if (currentDueDate != null)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'remove');
                },
                child: const Text('Remove deadline'),
              ),
          ],
        );
      },
    );

    if (option == null) {
      return currentDueDate;
    }

    if (option == 'remove') {
      return null;
    }

    DateTime? selectedDate;

    if (option == 'today') {
      selectedDate = DateTimeService.endOfDay(now);
    } else if (option == 'tomorrow') {
      selectedDate = DateTimeService.endOfDay(
        now.add(const Duration(days: 1)),
      );
    } else if (option == 'nextWeek') {
      selectedDate = DateTimeService.endOfDay(
        now.add(const Duration(days: 7)),
      );
    } else if (option == "maxLength"){
      selectedDate = maximumDueDate;
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: currentDueDate ?? now,
        firstDate: DateTime(
          now.year,
          now.month,
          now.day,
        ),
        lastDate: maximumDueDate ?? DateTime(now.year + 10),
      );

      if (date == null) {
        return currentDueDate;
      }

      final time = await showTimePicker(
        context: context,
        initialTime: currentDueDate != null
            ? TimeOfDay.fromDateTime(currentDueDate)
            : TimeOfDay.now(),
      );

      if (time == null) {
        return currentDueDate;
      }

      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    // Si existe una fecha máxima, no podemos superarla.
    if (maximumDueDate != null &&
        selectedDate!.isAfter(maximumDueDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The deadline cannot be later than the quest deadline.',
          ),
        ),
      );

      return currentDueDate;
    }

    return selectedDate;
  }

  void _showTaskDialog(
      BuildContext context, {
        DateTime? questDueDate,
        TaskModel? task,
        Function(TaskModel)? onTaskCreated,
        Function(TaskModel)? onTaskEdited,
      }) {
    final titleController = TextEditingController(
      text: task?.title ?? "",
    );

    // Contador actual de la tarea.
    final currentCountController = TextEditingController(
      text: task?.currentCount?.toString() ?? "",
    );

    // Objetivo total de la tarea.
    final targetCountController = TextEditingController(
      text: task?.targetCount?.toString() ?? "",
    );

    // Fecha límite actual de la tarea, si estamos editándola.
    DateTime? dueDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                task == null ? "New Task" : "Edit Task",
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -------------------------
                  // TÍTULO
                  // -------------------------
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------
                  // CONTADOR ACTUAL
                  // -------------------------
                  TextField(
                    controller: currentCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Current Count",
                      hintText: "Ej. 23",
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------
                  // OBJETIVO
                  // -------------------------
                  TextField(
                    controller: targetCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Target Count",
                      hintText: "Ej. 50",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------
                  // FECHA LÍMITE
                  // -------------------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Due Date",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        print(questDueDate);

                        final selectedDate =
                        await _selectDueDate(
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
                            ? "No deadline"
                            : DateTimeService.formatDateTime(
                          dueDate!,
                        ),
                      ),
                    ),
                  ),

                  // -------------------------
                  // FECHA DE LA QUEST
                  // -------------------------
                  if (questDueDate != null) ...[
                    const SizedBox(height: 8),

                    Text(
                      "Quest deadline: "
                          "${DateTimeService.formatDateTime(questDueDate)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),

              // -------------------------
              // BOTONES
              // -------------------------
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

                    // El título no puede estar vacío.
                    if (title.isEmpty) {
                      return;
                    }

                    // -------------------------
                    // VALIDAR CONTADOR
                    // -------------------------

                    final currentCount =
                    int.tryParse(
                      currentCountController.text.trim(),
                    );

                    final targetCount =
                    int.tryParse(
                      targetCountController.text.trim(),
                    );

                    // Si uno de los dos está rellenado,
                    // ambos deben estarlo.
                    if ((currentCount == null) !=
                        (targetCount == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current Count and Target Count must both be filled.',
                          ),
                        ),
                      );
                      return;
                    }

                    // El contador actual no puede ser negativo.
                    if (currentCount != null &&
                        currentCount < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current Count cannot be negative.',
                          ),
                        ),
                      );
                      return;
                    }

                    // El objetivo debe ser mayor que 0.
                    if (targetCount != null &&
                        targetCount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Target Count must be greater than 0.',
                          ),
                        ),
                      );
                      return;
                    }

                    // El contador actual no puede superar
                    // el objetivo.
                    if (currentCount != null &&
                        targetCount != null &&
                        currentCount > targetCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current Count cannot be greater than Target Count.',
                          ),
                        ),
                      );
                      return;
                    }

                    // -------------------------
                    // VALIDAR FECHA
                    // -------------------------

                    // La fecha de la tarea no puede superar
                    // la fecha de la quest.
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

                    // -------------------------
                    // CREAR TASK
                    // -------------------------
                    if (task == null) {
                      final newTask = TaskModel(
                        title: title,
                        dueDate: dueDate,
                        currentCount: currentCount,
                        targetCount: targetCount,
                      );

                      onTaskCreated?.call(newTask);
                    }

                    // -------------------------
                    // EDITAR TASK
                    // -------------------------
                    else {
                      task.setTitle(title);
                      task.setDueDate(dueDate!);

                      task.setCurrentCount(currentCount!);
                      task.setTargetCount(targetCount!);

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
      },
    );
  }
}