import '../models/quest_model.dart';
import '../services/storage_service.dart';
import 'quest_repository.dart';

class HiveQuestRepository implements QuestRepository {
  final StorageService _storage;

  HiveQuestRepository(this._storage);

  @override
  Future<List<QuestModel>> getAll() {
    return _storage.loadQuests();
  }

  @override
  Future<List<QuestModel>> getArchived() {
    return _storage.loadArchivedQuests();
  }

  @override
  Future<void> saveAllQuests(List<QuestModel> quests) {
    return _storage.saveQuests(quests);
  }

  @override
  Future<void> saveArchived(List<QuestModel> quests) {
    return _storage.saveArchivedQuests(quests);
  }

  @override
  Future<void> clearAll() async {
    await _storage.saveQuests([]);
    await _storage.saveArchivedQuests([]);
  }
}