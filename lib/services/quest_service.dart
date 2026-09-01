import 'package:flutter/cupertino.dart';
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

  Future<void> updateQuest(String questId, { String? newTitle, int? newExpReward, bool changeCompletion = false, bool togglePause = false,}) async {
    final quest = _quests.cast<QuestModel?>().firstWhere(
          (q) => q?.id == questId,
      orElse: () => null,
    );

    if (quest == null) {
      return;
    }

    if (newTitle != null) {
      quest.setTitle(newTitle);
    }
    if (newExpReward != null) {
      quest.setExperienceReward(newExpReward);
    }
    if (changeCompletion) {
      quest.changeCompletion();
      if (quest.completed) {
        _playerService.addExperience(quest.experienceReward);
      } else {
        _playerService.addExperience(-quest.experienceReward);
      }
    }
    if (togglePause){
      quest.togglePaused();
    }

    await _saveAndSync();
  }
}