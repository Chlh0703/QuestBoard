import 'package:flutter/cupertino.dart';

import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../services/quest_service.dart';

class QuestController {
  final QuestService _questService;

  QuestController(this._questService);

  List<QuestModel> get quests => _questService.quests;
  List<QuestModel> get archivedQuests => _questService.archivedQuests;

  Listenable get listenable => _questService;

  Future<void> addQuest(QuestModel quest) async {
    await _questService.addQuest(quest);
  }

  Future<void> togglePause(QuestModel quest) async {
    await _questService.updateQuest(
      quest.id,
      togglePause: true,
    );
  }

  Future<void> updateQuest(String questId, {
    // Quest
    String? newTitle, int? newExpReward, bool togglePause = false, int? newClassification, DateTime? newDueDate, DateTime? newStartDate, DateTime? newRepeatEnd,
    // Tasks
    List<TaskModel>? newTasks, String? taskId, String? newTaskTitle, DateTime? newTaskDueDate, int? newCurrentCount, int? newTargetCount, String? newDescription, bool? taskTapped,
  }) async {
    await _questService.updateQuest(questId,
      newTitle: newTitle, newExpReward: newExpReward, togglePause: togglePause, newClassification: newClassification, newDueDate: newDueDate, newStartDate: newStartDate, newRepeatEnd: newRepeatEnd,
      newTasks: newTasks, taskId: taskId, newTaskTitle: newTaskTitle, newTaskDueDate: newTaskDueDate, newCurrentCount: newCurrentCount, newTargetCount: newTargetCount, newDescription: newDescription, taskTapped: taskTapped,
    );
  }

  Future<void> archiveQuest(QuestModel quest) async {
    await _questService.archiveQuest(quest);
  }

  Future<void> restoreQuest(QuestModel quest) async {
    await _questService.restoreQuest(quest);
  }

  Future<void> removeArchivedQuest(QuestModel quest) async {
    await _questService.removeArchivedQuest(quest);
  }

  Future<void> completeTask(
      QuestModel quest,
      TaskModel task,
      ) async {
    await _questService.updateQuest(
      quest.id,
      taskId: task.id,
      taskTapped: true,
    );
  }
}