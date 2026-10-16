import 'package:hive_flutter/hive_flutter.dart';
import 'package:quest_board/models/player_statistics.dart';
import 'package:quest_board/services/player_achievements.dart';

import '../models/quest_model.dart';
import '../models/player_model.dart';
import '../models/task_model.dart';

class StorageService {
  static const String questBoxName = "quests";
  static const String archivedQuestBoxName = "archived_quests";
  static const String playerBoxName = 'player';
  static const String statisticsBoxName = 'statistics';
  static const String achievementBoxName = 'achievement_states';

  Box<QuestModel> get _questBox =>
      Hive.box<QuestModel>(questBoxName);

  Box<QuestModel> get _archivedQuestBox =>
      Hive.box<QuestModel>(archivedQuestBoxName);

  Box<PlayerModel> get _playerBox =>
      Hive.box<PlayerModel>(playerBoxName);

  Box<PlayerStatistics> get _statisticsBox =>
      Hive.box<PlayerStatistics>(statisticsBoxName);

  Box get _achievementBox =>
      Hive.box(achievementBoxName);

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(QuestModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PlayerModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TaskModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(PlayerStatisticsAdapter());

    await Hive.openBox<QuestModel>(questBoxName);
    await Hive.openBox<PlayerModel>(playerBoxName);
    await Hive.openBox<QuestModel>(archivedQuestBoxName);
    await Hive.openBox<PlayerStatistics>(statisticsBoxName);
    await Hive.openBox(achievementBoxName);
  }


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
    return _statisticsBox.get('player_statistics');
  }

  Future<void> saveStatistics(PlayerStatistics statistics) async {
    await _statisticsBox.clear();
    await _statisticsBox.put('player_statistics', statistics);
  }

  // Recupera el estado guardado de un achievement.
  Map<dynamic, dynamic>? loadAchievementState(String id) {
    final box = Hive.box(achievementBoxName);

    final data = box.get(id);

    if (data is Map) {
      return data;
    }

    return null;
  }

  // Guarda el estado de un achievement.
  Future<void> saveAchievementState(
      String id, {
        required bool unlocked,
        DateTime? unlockedAt,
      }) async {

    await _achievementBox.put(id, {
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    });
  }

  static Future<void> clearDatabase() async {
    await Hive.box<QuestModel>(questBoxName).close();
    await Hive.box<QuestModel>(archivedQuestBoxName).close();
    await Hive.box<PlayerModel>(playerBoxName).close();
    await Hive.box<PlayerStatistics>(statisticsBoxName).close();
    await Hive.box(achievementBoxName).close();

    await Hive.deleteBoxFromDisk(questBoxName);
    await Hive.deleteBoxFromDisk(archivedQuestBoxName);
    await Hive.deleteBoxFromDisk(playerBoxName);
    await Hive.deleteBoxFromDisk(statisticsBoxName);
    await Hive.deleteBoxFromDisk(achievementBoxName);
  }
}