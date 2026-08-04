import 'package:hive_flutter/hive_flutter.dart';

import '../models/quest_model.dart';

class StorageService {

  static const String _boxName = "quests";

  Box<QuestModel> get _box => Hive.box<QuestModel>(_boxName);

  List<QuestModel> loadQuests() {
    return _box.values.toList();
  }

  Future<void> saveQuests(List<QuestModel> quests) async {
    await _box.clear();
    await _box.addAll(quests);
  }

}