import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/game_model.dart';
import 'storage_service.dart';

class GameService extends ChangeNotifier {
  static const int boardWidth = 6;
  static const int boardCellCount = boardWidth * boardWidth;

  final StorageService _storage;
  final Random _random = Random();
  late GameModel _game;
  bool _initialized = false;

  GameService(this._storage);

  int get levelNumber => _game.levelNumber;
  int get seriesNumber => ((_game.levelNumber - 1) ~/ 15) + 1;
  int get levelInSeries => ((_game.levelNumber - 1) % 15) + 1;
  int get energyUsed => _game.energyUsed;
  int get energyRemaining => _game.energyRemaining;
  int get stateCount => seriesNumber == 2 ? 4 : 2;
  List<int> get brush => List.unmodifiable(_game.brush);
  List<int> get board => List.unmodifiable(_game.board);
  List<int> get target => List.unmodifiable(_targetForCurrentLevel());
  bool get isSolved => _matches(_game.board, _targetForCurrentLevel());

  Future<void> initialize() async {
    final savedGame = await _storage.loadGame();
    if (savedGame == null) {
      _game = GameModel(brush: _createRandomBrush());
      await _storage.saveGame(_game);
    } else {
      _game = savedGame;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> tapCell(int row, int column) async {
    _ensureInitialized();
    if (isSolved) return;
    if (energyRemaining <= 0) return;

    _game.board = _applyBrush(
      _game.board,
      row,
      column,
      _game.brush,
      stateCount,
    );
    _game.useEnergy();
    notifyListeners();
    await _storage.saveGame(_game);
  }

  Future<void> restartLevel() async {
    _ensureInitialized();
    _game.board = List<int>.filled(boardCellCount, 0);
    notifyListeners();
    await _storage.saveGame(_game);
  }

  Future<void> forfeitLevel() async {
    _ensureInitialized();
    _game.levelNumber = _game.levelNumber > 3 ? _game.levelNumber - 3 : 1;
    _game.board = List<int>.filled(boardCellCount, 0);
    _game.brush = _createRandomBrush();
    notifyListeners();
    await _storage.saveGame(_game);
  }

  Future<bool> advanceToNextLevel() async {
    _ensureInitialized();
    if (!isSolved || _game.levelNumber == 30) return false;

    _game.levelNumber++;
    _game.brush = _createRandomBrush();
    _game.board = List<int>.filled(boardCellCount, 0);
    notifyListeners();
    await _storage.saveGame(_game);
    return true;
  }

  List<int> _targetForCurrentLevel() {
    var brushCode = 0;
    for (final cell in _game.brush) {
      brushCode = (brushCode << 1) | cell;
    }
    // Agafar segons el nivel aixi es
    final random = Random(_game.levelNumber * 512 + brushCode);
    final minimumTaps = levelInSeries;
    final tapCount = minimumTaps + random.nextInt((minimumTaps * 2) - minimumTaps + 1);
    var randomTarget = List<int>.filled(boardCellCount, 0);

    for (var tap = 0; tap < tapCount; tap++) {
      randomTarget = _applyBrush(
        randomTarget,
        random.nextInt(boardWidth),
        random.nextInt(boardWidth),
        _game.brush,
        stateCount,
      );
    }

    return randomTarget;
  }

  List<int> _createRandomBrush() {
    final brush = List<int>.filled(3 * 3, 0);
    brush[brush.length ~/ 2] = 1;

    for (var index = 0; index < brush.length; index++) {
      if (index == brush.length ~/ 2) {
        brush[brush.length ~/ 2] = 1;
      } else if (_random.nextBool()) {
        brush[index] = 1;
      }
    }

    return brush;
  }

  List<int> _applyBrush(
    List<int> currentBoard,
    int row,
    int column,
    List<int> brush,
    int numberOfStates,
  ) {
    if (row < 0 || row >= boardWidth || column < 0 || column >= boardWidth) {
      throw RangeError('Tapped cell must be inside the 6×6 board.');
    }

    final nextBoard = List<int>.of(currentBoard);
    const brushWidth = 3;
    for (int brushIndex = 0; brushIndex < brush.length; brushIndex++) {
      if (brush[brushIndex] == 0) continue;

      final brushRow = brushIndex ~/ brushWidth;
      final brushColumn = brushIndex % brushWidth;
      final affectedRow = row + brushRow - brushWidth ~/ 2;
      final affectedColumn = column + brushColumn - brushWidth ~/ 2;

      if (affectedRow < 0 || affectedRow >= boardWidth || affectedColumn < 0 || affectedColumn >= boardWidth) {
        continue;
      }

      final index = affectedRow * boardWidth + affectedColumn;
      nextBoard[index] = (nextBoard[index] + 1) % numberOfStates;
    }
    return nextBoard;
  }

  bool _matches(List<int> currentBoard, List<int> targetBoard) {
    for (var index = 0; index < boardCellCount; index++) {
      if (currentBoard[index] != targetBoard[index]) return false;
    }
    return true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('GameService.initialize() must be called first.');
    }
  }
}
