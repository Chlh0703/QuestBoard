import 'dart:math';

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

  int experienceRequiredForNextLevel([int? level]){
    final currentLevel = level ?? this.level;
    return 100 + (currentLevel - 1) * 50;
  }

  void addMaxHp(int amount){
    maxHealth += amount;
  }

  void addHp(int amount){
    currentHealth += amount;
    if (currentHealth > maxHealth) currentHealth = maxHealth;
    if (currentHealth < 0) currentHealth = 0;
    return;
  }

  void addExperience(int amount){
    experience += amount;
    if (experience >= 0) {
      while (experience >= experienceRequiredForNextLevel()) {
        experience -= experienceRequiredForNextLevel();
        level++;
      }
      return;
    }
    while (experience < 0) {
      level--;
      if (level < 1 && experience < 0) {
        experience = 0;
        level = 1;
        return;
      }
      experience += experienceRequiredForNextLevel(level);
    }
  }
}