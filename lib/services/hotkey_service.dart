import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';

class HotkeyService {
  // Static significa que no cal rcear instancia, Future void esque es asincrona y no se espera nada a devolver
  // Guarda una funcion como variable (VoidCallback)
  static Future<void> initialize({required VoidCallback showOverlay,}) async {
    await hotKeyManager.unregisterAll(); // Elimina los atajos previos
    final hotKey = HotKey(  // Definicion del botón que queremos hacer
      key: PhysicalKeyboardKey.keyS,
      modifiers: [
        HotKeyModifier.control,
      ],
      scope: HotKeyScope.system, // Esto es para definir que funciona en el sistema completamente, aunque no tenga foco en el
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) {
        showOverlay(); // Llama a la funcion que tiene guardada como variable ^
      },
    );
  }

}