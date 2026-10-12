// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatisticsAdapter extends TypeAdapter<PlayerStatistics> {
  @override
  final int typeId = 4;

  @override
  PlayerStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStatistics(
      completedQuestsByType: (fields[0] as List?)?.cast<int>(),
      totalExperienceEarned: fields[1] as int,
      questsCreated: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStatistics obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.completedQuestsByType)
      ..writeByte(1)
      ..write(obj.totalExperienceEarned)
      ..writeByte(2)
      ..write(obj.questsCreated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
