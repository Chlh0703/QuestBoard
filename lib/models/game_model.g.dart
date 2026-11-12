// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameModelAdapter extends TypeAdapter<GameModel> {
  @override
  final int typeId = 6;

  @override
  GameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameModel(
      board: (fields[0] as List?)?.cast<int>(),
      levelNumber: fields[1] as int,
      brush: (fields[2] as List?)?.cast<int>(),
      energyUsed: fields[3] as int,
      energyRemaining: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.board)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.brush)
      ..writeByte(3)
      ..write(obj.energyUsed)
      ..writeByte(4)
      ..write(obj.energyRemaining);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
