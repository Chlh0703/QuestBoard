import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quest_board/services/notification_service.dart';
import 'package:quest_board/services/quest_notification_scheduler.dart';
import 'package:quest_board/services/quest_service.dart';

import 'hotkey_service.dart';
import 'overlay_service.dart';

class ConfigurationService {
  Future<void> updateHotkey({required HotKeyModifier modifier, required PhysicalKeyboardKey key,}) async {
    try {
      await HotkeyService.updateHotkey(
        modifier: modifier,
        key: key,
      );
    } catch (error) {
      throw Exception('Failed to update the keyboard shortcut: $error');
    }
  }

  Future<void> setOverlayAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await OverlayService.setAlwaysOnTop(alwaysOnTop);
    } catch (error) {
      throw Exception('Failed to set Overlay status: $error');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await QuestService.setNotificationsEnabled(enabled);
    } catch (error) {
      throw Exception('Failed to update notification state: $error');
    }
  }
}