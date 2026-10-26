import '../models/quest_model.dart';

abstract interface class QuestOverlayNotifier {
  Future<void> questsChanged(List<QuestModel> quests);
}