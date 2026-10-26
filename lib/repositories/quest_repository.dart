import '../models/quest_model.dart';

abstract interface class QuestRepository {
  Future<List<QuestModel>> getAll();

  Future<List<QuestModel>> getArchived();

  Future<void> saveAll(List<QuestModel> quests);

  Future<void> saveArchived(List<QuestModel> quests);

  Future<void> clearAll();
}