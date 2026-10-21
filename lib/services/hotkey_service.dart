import 'package:flutter/cupertino.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';

class HotkeyService extends ChangeNotifier {
  // Static significa que no cal rcear instancia, Future void esque es asincrona y no se espera nada a devolver
  // Guarda una funcion como variable (VoidCallback)
  static HotKeyModifier modifierKey = HotKeyModifier.control;
  static PhysicalKeyboardKey mainKey = PhysicalKeyboardKey.keyS;

  static VoidCallback? _showOverlay;

  static Future<void> initialize({required VoidCallback showOverlay,}) async {
    _showOverlay = showOverlay;
    await _registerHotkey();
  }

  static Future<void> _registerHotkey() async {
    await hotKeyManager.unregisterAll();
    final hotKey = HotKey(
      key: mainKey,
      modifiers: [modifierKey],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) {
        _showOverlay?.call();
      },
    );
  }

  static Future<void> updateHotkey({
    required HotKeyModifier modifier,
    required PhysicalKeyboardKey key,
  }) async {
    modifierKey = modifier;
    mainKey = key;
    await _registerHotkey();
  }
}