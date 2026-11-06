// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigurationModelAdapter extends TypeAdapter<ConfigurationModel> {
  @override
  final int typeId = 5;

  @override
  ConfigurationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigurationModel(
      hotkeyModifier: fields[0] as String,
      hotkeyMainKey: fields[1] as String,
      alwaysOnTop: fields[2] as bool,
      notificationsEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConfigurationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.hotkeyModifier)
      ..writeByte(1)
      ..write(obj.hotkeyMainKey)
      ..writeByte(2)
      ..write(obj.alwaysOnTop)
      ..writeByte(3)
      ..write(obj.notificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
