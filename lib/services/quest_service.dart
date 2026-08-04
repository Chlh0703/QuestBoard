import 'package:flutter/cupertino.dart';

import '../services/storage_service.dart';
import '../models/quest_model.dart';

class QuestService extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final List<QuestModel> _quests = [];

  List<QuestModel> get quests => List.unmodifiable(_quests);

  QuestService() {
    _quests.addAll(_storage.loadQuests());
  }

  Future<void> addQuest(QuestModel quest) async {
    _quests.add(quest);
    await _storage.saveQuests(_quests); // esto es basicamente un update de bd
    notifyListeners();
  }

  Future<void> removeQuest(QuestModel quest) async {
    if(_quests.contains(quest)){
      _quests.remove(quest);
      await _storage.saveQuests(_quests);
      notifyListeners();
    }
  }

  Future<void> updateQuest(QuestModel quest, { String? newTitle, String? newDescription, bool changeCompletion = false,}) async {
    if (!_quests.contains(quest)) return;
    if (newTitle != null) {
      quest.setTitle(newTitle);
    }
    if (newDescription != null) {
      quest.setDescription(newDescription);
    }
    if (changeCompletion) {
      quest.changeCompletion();
    }
    await _storage.saveQuests(_quests);
    notifyListeners();
  }
}