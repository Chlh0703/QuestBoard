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
      description: fields[2] as String,
      completed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj._title)
      ..writeByte(2)
      ..write(obj._description)
      ..writeByte(3)
      ..write(obj._completed);
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
