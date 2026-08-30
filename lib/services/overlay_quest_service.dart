import 'package:flutter/cupertino.dart';

import '../models/quest_model.dart';

class OverlayQuestService extends ChangeNotifier {
  final List<QuestModel> _quests = [];

  OverlayQuestService(List<QuestModel> quests) {
    replaceAll(quests);
  }

  List<QuestModel> get quests => List.unmodifiable(_quests);

  void replaceAll(List<QuestModel> quests) {
    _quests
      ..clear()
      ..addAll(quests);

    notifyListeners();
  }
}