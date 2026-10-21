import 'package:flutter/services.dart';

class OverlayService {
  static bool isAlwaysOnTop = true;

  static const MethodChannel _overlayChannel = MethodChannel('questboard/overlay'); // Variable del method Channel
  static const MethodChannel _mainChannel = MethodChannel('questboard/main');

  static Future<void> enableClickThrough() async {
    await _overlayChannel.invokeMethod('enableClickThrough');
  }

  static Future<void> disableClickThrough() async {
    await _overlayChannel.invokeMethod('disableClickThrough');
  }

  static Future<void> setAlwaysOnTop(bool value) async {
    await _mainChannel.invokeMethod('setAlwaysOnTop', value);
    isAlwaysOnTop = value;
  }
}