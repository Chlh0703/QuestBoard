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

  Future<void> addQuest(QuestModel quest) {
    return _questService.addQuest(quest);
  }

  Future<void> togglePause(QuestModel quest) {
    return _questService.updateQuest(
      quest.id,
      togglePause: true,
    );
  }

  Future<void> updateQuest(String questId, {
    String? newTitle,
    int? newExpReward,
    int? newClassification,
    DateTime? newDueDate,
    DateTime? newRepeatEnd,
    List<TaskModel>? newTasks
  }) {
    return _questService.updateQuest(questId,
      newTitle: newTitle,
      newExpReward: newExpReward,
      newClassification:
      newClassification,
      newDueDate: newDueDate,
      newRepeatEnd: newRepeatEnd,
      newTasks: newTasks,
    );
  }

  Future<void> resumePauseQuest(String questId){
    return _questService.updateQuest(questId, togglePause: true,);
  }

  Future<void> archiveQuest(QuestModel quest) {
    return _questService.archiveQuest(quest);
  }

  Future<void> restoreQuest(QuestModel quest) {
    return _questService.restoreQuest(quest);
  }

  Future<void> removeArchivedQuest(QuestModel quest) {
    return _questService.removeArchivedQuest(quest);
  }

  Future<void> completeTask(String questId, String taskId,) {
    return _questService.updateQuest(questId, taskId: taskId);
  }
}