import 'package:flutter/cupertino.dart';

import '../models/quest.dart';

class QuestService extends ChangeNotifier {
  final List<Quest> _quests = [];

  List<Quest> get quests => _quests;

  void addQuest(Quest quest){
    _quests.add(quest);
    notifyListeners();
  }

  void removeQuest(Quest quest){
    if(_quests.contains(quest)){
      _quests.remove(quest);
      notifyListeners();
    }
  }

  void updateQuest(Quest quest, { String? newTitle, String? newDescription, bool changeCompletion = false,}) {
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
    notifyListeners();
  }
}