import 'package:hive/hive.dart';

part 'configuration_model.g.dart';

@HiveType(typeId: 5)
class ConfigurationModel extends HiveObject {
  @HiveField(0)
  String hotkeyModifier;

  @HiveField(1)
  String hotkeyMainKey;

  @HiveField(2)
  bool alwaysOnTop;

  @HiveField(3)
  bool notificationsEnabled;

  ConfigurationModel({
    this.hotkeyModifier = 'control',
    this.hotkeyMainKey = 'Key S',
    this.alwaysOnTop = true,
    this.notificationsEnabled = true,
  });
}
