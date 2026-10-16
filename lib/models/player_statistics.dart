import 'package:hive/hive.dart';

part 'player_statistics.g.dart';

@HiveType(typeId: 4)
class PlayerStatistics {
  @HiveField(0)
  List<int> completedQuestsByType;

  @HiveField(1)
  int totalExperienceEarned;

  @HiveField(2)
  int questsCreated;

  PlayerStatistics({
    List<int>? completedQuestsByType,
    this.totalExperienceEarned = 0,
    this.questsCreated = 0,
  }): completedQuestsByType = completedQuestsByType ?? [0, 0, 0];

  void registerQuestCompleted(int classification, bool positive) {
    if (classification < 1 || classification > 3) {
      return;
    }

    final index = classification - 1;

    if (positive) {
      completedQuestsByType[index]++;
    } else if (completedQuestsByType[index] > 0) {
      completedQuestsByType[index]--;
    }
  }

}