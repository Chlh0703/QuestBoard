import 'package:flutter/cupertino.dart';

import '../models/quest_model.dart';

class OverlayQuestService extends ChangeNotifier {
  final List<QuestModel> _quests = [];

  OverlayQuestService(List<QuestModel> quests) {
    print("inside init overlay quest service $quests");
    replaceAll(quests);
    print("inside init overlay quest service 2 $_quests");
  }

  List<QuestModel> get quests => List.unmodifiable(_quests);

  void replaceAll(List<QuestModel> quests) {
    _quests
      ..clear()
      ..addAll(quests);

    notifyListeners();
  }
}