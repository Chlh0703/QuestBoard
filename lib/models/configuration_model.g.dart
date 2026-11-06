// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_model.dart';

class ConfigurationModelAdapter extends TypeAdapter<ConfigurationModel> {
  @override
  final int typeId = 5;

  @override
  ConfigurationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
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
}
