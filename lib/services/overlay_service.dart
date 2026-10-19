import 'package:flutter/services.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel('questboard/overlay'); // Variable del method Channel

  static Future<void> enableClickThrough() async {
    await _channel.invokeMethod('enableClickThrough');
  }

  static Future<void> disableClickThrough() async {
    await _channel.invokeMethod('disableClickThrough');
  }

  static Future<void> setDragRegion({
    required double x,
    required double y,
    required double width,
    required double height,
    required double viewWidth,
    required double viewHeight,
  }) async {
    await _channel.invokeMethod('setDragRegion', {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'viewWidth': viewWidth,
      'viewHeight': viewHeight,
    });
  }

}