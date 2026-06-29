import 'package:flutter/foundation.dart';

import 'overlay_service.dart';

class OverlayController extends ChangeNotifier { // Controllador de overlay
  bool visible = true;

  Future<void> show() async {
    visible = true;
    await OverlayService.disableClickThrough();
    notifyListeners();
  }

  Future<void> hide() async {
    visible = false;
    print("intentando hiddear, ya ultimo");
    await OverlayService.enableClickThrough();
    notifyListeners();
  }

  void toggle() {
    visible = !visible;
    notifyListeners();
  }

}