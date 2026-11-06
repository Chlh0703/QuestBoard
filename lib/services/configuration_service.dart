import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quest_board/services/quest_service.dart';
import 'package:quest_board/models/configuration_model.dart';

import 'hotkey_service.dart';
import 'overlay_service.dart';
import 'storage_service.dart';

class ConfigurationService {
  ConfigurationService([StorageService? storage])
    : _storage = storage ?? StorageService();

  final StorageService _storage;

  Future<ConfigurationModel> loadConfiguration() async =>
      _storage.loadConfiguration();

  Future<void> _updateConfiguration(void Function(ConfigurationModel configuration) update,) async {
    final configuration = await loadConfiguration();
    update(configuration);
    await _storage.saveConfiguration(configuration);
  }

  Future<void> updateHotkey({
    required HotKeyModifier modifier,
    required PhysicalKeyboardKey key,
  }) async {
    try {
      await HotkeyService.updateHotkey(modifier: modifier, key: key);
      await _updateConfiguration((configuration) {
        configuration.hotkeyModifier = modifier.name;
        configuration.hotkeyMainKey = key.debugName ?? key.keyLabel;
      });
    } catch (error) {
      throw Exception('Failed to update the keyboard shortcut: $error');
    }
  }

  Future<void> setOverlayAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await OverlayService.setAlwaysOnTop(alwaysOnTop);
      await _updateConfiguration((configuration) {
        configuration.alwaysOnTop = alwaysOnTop;
      });
    } catch (error) {
      throw Exception('Failed to set Overlay status: $error');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await QuestService.setNotificationsEnabled(enabled);
      await _updateConfiguration((configuration) {
        configuration.notificationsEnabled = enabled;
      });
    } catch (error) {
      throw Exception('Failed to update notification state: $error');
    }
  }
}
