import 'package:hive/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 2)
class PlayerModel extends HiveObject {
  @HiveField(0)
  int experience;

  @HiveField(1)
  int level;

  @HiveField(2)
  int maxHealth;

  @HiveField(3)
  int currentHealth;

  PlayerModel({
    this.experience = 0,
    this.level = 1,
    this.maxHealth = 1,
    this.currentHealth = 1,
  });
}