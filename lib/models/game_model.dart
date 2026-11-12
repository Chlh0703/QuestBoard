import 'package:hive/hive.dart';

part 'game_model.g.dart';

@HiveType(typeId: 6)
class GameModel extends HiveObject {
  @HiveField(0)
  List<int> board;

  @HiveField(1)
  int levelNumber;

  @HiveField(2)
  List<int> brush;

  @HiveField(3)
  int energyUsed;

  @HiveField(4)
  int energyRemaining;

  GameModel({
    List<int>? board,
    this.levelNumber = 1,
    List<int>? brush,
    this.energyUsed = 0,
    this.energyRemaining = 0,
  }) : board = List<int>.of(board ?? List<int>.filled(25, 0)),
       brush = List<int>.of(brush ?? _centerBrush());

  static List<int> _centerBrush() => [0, 0, 0, 0, 1, 0, 0, 0, 0];
}
