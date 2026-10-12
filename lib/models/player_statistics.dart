import 'package:hive/hive.dart';

part 'player_statistics.g.dart';

@HiveType(typeId: 4)
class PlayerStatistics {
  @HiveField(0)
  int completedQuests;

  @HiveField(1)
  int completedTasks;

  @HiveField(2)
  int totalExperienceEarned;

  @HiveField(3)
  int questsCreated;

  PlayerStatistics({
    this.completedQuests = 0,
    this.completedTasks = 0,
    this.totalExperienceEarned = 0,
    this.questsCreated = 0,
  });
}