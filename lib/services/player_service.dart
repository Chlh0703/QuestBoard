import 'package:flutter/foundation.dart';
import 'package:quest_board/models/quest_model.dart';

import '../models/player_model.dart';
import 'storage_service.dart';

class PlayerService extends ChangeNotifier {
  final StorageService _storage = StorageService();

  PlayerModel? _player;

  PlayerModel get player => _player!;

  Future<void> initialize() async {
    _player = await _storage.loadPlayer();
    notifyListeners();
  }

  Future<void> _saveAndSync() async {
    await _storage.savePlayer(player);
  }

  void addExperience(int amount){
    _player?.addExperience(amount);
    _saveAndSync();
  }

}