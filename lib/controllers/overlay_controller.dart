import 'package:flutter/foundation.dart';

import '../services/overlay_service.dart';

class OverlayController extends ChangeNotifier { // Controllador de overlay
  bool visible = false;
  static bool alwaysOnTop = true;

  Future<void> show() async {
    visible = true;
    await OverlayService.disableClickThrough();
    notifyListeners();
  }

  Future<void> hide() async {
    visible = false;
    await OverlayService.enableClickThrough();
    notifyListeners();
  }

  static Future<void> setAlwaysOnTop(bool value) async {
    await OverlayService.setAlwaysOnTop(value);
    alwaysOnTop = value;
  }
}