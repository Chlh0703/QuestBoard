import 'package:flutter/cupertino.dart';
import 'package:quest_board/models/task_model.dart';
import 'package:quest_board/services/player_service.dart';
import 'package:quest_board/services/window_service.dart';

import '../services/storage_service.dart';
import '../models/quest_model.dart';

class QuestService extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final PlayerService _playerService;
  final List<QuestModel> _quests = [];

  QuestService(this._playerService);

  List<QuestModel> get quests => List.unmodifiable(_quests);

  Future<void> initialize() async {
    await loadQuests();
  }

  Future<void> loadQuests() async {
    _quests
      ..clear()
      ..addAll(await _storage.loadQuests());
    notifyListeners();
  }

  Future<void> _saveAndSync() async {
    await _storage.saveQuests(_quests);

    // Refresca esta instancia del QuestService
    await loadQuests();

    // Envía el estado actualizado al Overlay
    await WindowService.sendQuestsToOverlay(_quests);
  }


  Future<void> addQuest(QuestModel quest) async {
    _quests.add(quest);
    await _saveAndSync();
  }

  Future<void> removeQuest(QuestModel quest) async {
    if(_quests.contains(quest)){
      _quests.remove(quest);
      await _saveAndSync();
    }
  }

  Future<void> updateQuest(String questId, {
        // Quest
        String? newTitle, int? newExpReward, bool togglePause = false, int? newClassification,
        // Tasks
        List<TaskModel>? newTasks, String? taskId, String? newTaskTitle, bool? changeTaskCompletion,
      }) async {
    final quest = _quests.cast<QuestModel?>().firstWhere(
          (q) => q?.id == questId,
      orElse: () => null,
    );

    if (quest == null) return;

    // Quest
    if (newTitle != null) {
      quest.setTitle(newTitle);
    }

    if (newExpReward != null) {
      quest.setExperienceReward(newExpReward);
    }

    if (togglePause) {
      quest.togglePaused();
    }

    if (newClassification != null) {
      quest.setClassification(newClassification);
    }

    // Tasks
    if (newTasks != null) {
      // Reemplazar toda la lista
      quest.setTasks(newTasks);
    } else if (taskId != null) {
      // Modificar una Task concreta
      final completionChanged = quest.updateTask(
        taskId,
        newTitle: newTaskTitle,
        changeCompletion: changeTaskCompletion,
      );

      if (completionChanged) {
        if (quest.completed) {
          _playerService.addExperience(quest.experienceReward);
        } else {
          _playerService.addExperience(-quest.experienceReward);
        }
      }
    }


    await _saveAndSync();
  }
}