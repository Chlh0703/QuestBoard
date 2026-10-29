import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
}