import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quest_board/models/player_statistics.dart';

import '../models/player_model.dart';
import 'storage_service.dart';

class PlayerService extends ChangeNotifier {
  final StorageService _storage = StorageService();

  PlayerModel? _player;
  PlayerStatistics? _playerStatistics;

  PlayerModel get player => _player!;

  PlayerStatistics get statistics => _playerStatistics!;

  Future<void> initialize() async {
    _player = await _storage.loadPlayer();
    _playerStatistics = await _storage.loadStatistics();

    if (_playerStatistics == null) {
      _playerStatistics = PlayerStatistics();
      await _storage.saveStatistics(_playerStatistics!);
    }

    notifyListeners();
  }

  Future<void> saveAndSync() async {
    await _storage.savePlayer(player);
    await _storage.saveStatistics(statistics);
  }

  Future<void> addExperience(int amount) async {
    _player?.addExperience(amount);
    _playerStatistics?.totalExperienceEarned += amount;
    await saveAndSync();
    notifyListeners();
  }

  Future<void> takeDamage(int amount) async {
    _player?.addHp(-amount);
    await _storage.savePlayer(player);
    notifyListeners();
  }

}