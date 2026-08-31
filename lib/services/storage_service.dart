import 'package:hive_flutter/hive_flutter.dart';

import '../models/quest_model.dart';
import '../models/player_model.dart';

class StorageService {

  static const String questBoxName = "quests";
  static const String playerBoxName = 'player';

  Box<QuestModel> get _box =>
      Hive.box<QuestModel>(questBoxName);

  Box<PlayerModel> get _playerBox =>
      Hive.box<PlayerModel>(playerBoxName);

  Future<List<QuestModel>> loadQuests() async {
    return _box.values.toList();
  }

  Future<void> saveQuests(List<QuestModel> quests) async {
    await _box.clear();
    await _box.addAll(quests);
  }

  Future<PlayerModel> loadPlayer() async {
    final player = _playerBox.get('player');
    if (player != null) {
      return player;
    }

    final newPlayer = PlayerModel();
    await _playerBox.put('player', newPlayer);
    return newPlayer;

  }

  Future<void> savePlayer(PlayerModel player) async {
    await _playerBox.put('player', player);
  }

  Future<void> clearDatabase() async {
    if (Hive.isBoxOpen(questBoxName)) {
      await Hive.box<QuestModel>(questBoxName).close();
    }

    if (Hive.isBoxOpen(playerBoxName)) {
      await Hive.box(playerBoxName).close();
    }

    await Hive.deleteBoxFromDisk(questBoxName);
    await Hive.deleteBoxFromDisk(playerBoxName);

  }

}