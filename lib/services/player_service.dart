import 'package:flutter/foundation.dart';

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
}