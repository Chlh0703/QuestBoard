import 'package:flutter/services.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel('questboard/overlay'); // Variable del method Channel

  static Future<void> enableClickThrough() async {
    await _channel.invokeMethod(
      'enableClickThrough',
    );
  }

  static Future<void> disableClickThrough() async {
    await _channel.invokeMethod(
      'disableClickThrough',
    );
  }
}