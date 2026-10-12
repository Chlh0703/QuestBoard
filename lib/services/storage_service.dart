import 'package:hive_flutter/hive_flutter.dart';
import 'package:quest_board/models/player_statistics.dart';

import '../models/quest_model.dart';
import '../models/player_model.dart';

class StorageService {

  static const String questBoxName = "quests";
  static const String archivedQuestBoxName = "archived_quests";
  static const String playerBoxName = 'player';
  static const String statisticsBoxName = 'statistics';

  Box<QuestModel> get _questBox =>
      Hive.box<QuestModel>(questBoxName);

  Box<QuestModel> get _archivedQuestBox =>
      Hive.box<QuestModel>(archivedQuestBoxName);

  Box<PlayerModel> get _playerBox =>
      Hive.box<PlayerModel>(playerBoxName);

  Box<PlayerStatistics> get _statisticsBoxName =>
      Hive.box<PlayerStatistics>(statisticsBoxName);

  Future<List<QuestModel>> loadQuests() async {
    return _questBox.values.toList();
  }

  Future<void> saveQuests(List<QuestModel> quests) async {
    await _questBox.clear();
    await _questBox.addAll(quests);
  }


  Future<List<QuestModel>> loadArchivedQuests() async {
    return _archivedQuestBox.values.toList();
  }

  Future<void> saveArchivedQuests(List<QuestModel> quests,) async {
    await _archivedQuestBox.clear();
    await _archivedQuestBox.addAll(quests);
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

  Future<PlayerStatistics?> loadStatistics() async {
    return _statisticsBoxName.get('player_statistics');
  }

  Future<void> saveStatistics(PlayerStatistics statistics) async {
    await _statisticsBoxName.clear();
    await _statisticsBoxName.put('player_statistics', statistics);
  }


  Future<void> clearDatabase() async {
    if (Hive.isBoxOpen(questBoxName)) {
      await Hive.box<QuestModel>(questBoxName).close();
    }

    if (Hive.isBoxOpen(archivedQuestBoxName)) {
      await Hive.box<QuestModel>(archivedQuestBoxName).close();
    }

    if (Hive.isBoxOpen(playerBoxName)) {
      await Hive.box(playerBoxName).close();
    }

    if (Hive.isBoxOpen(statisticsBoxName)) {
      await Hive.box(statisticsBoxName).close();
    }

    await Hive.deleteBoxFromDisk(questBoxName);
    await Hive.deleteBoxFromDisk(archivedQuestBoxName);
    await Hive.deleteBoxFromDisk(playerBoxName);
    await Hive.deleteBoxFromDisk(statisticsBoxName);
  }
}