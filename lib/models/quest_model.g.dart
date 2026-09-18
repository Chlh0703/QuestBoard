// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestModelAdapter extends TypeAdapter<QuestModel> {
  @override
  final int typeId = 1;

  @override
  QuestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      experienceReward: fields[3] as int,
      completed: fields[2] as bool,
      paused: fields[4] as bool,
      classification: fields[5] as int,
    ).._tasks = (fields[6] as List).cast<TaskModel>();
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj._title)
      ..writeByte(2)
      ..write(obj._completed)
      ..writeByte(3)
      ..write(obj._experienceReward)
      ..writeByte(4)
      ..write(obj._paused)
      ..writeByte(5)
      ..write(obj._classification)
      ..writeByte(6)
      ..write(obj._tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
