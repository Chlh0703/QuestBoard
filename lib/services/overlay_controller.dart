import 'package:flutter/foundation.dart';

class OverlayController extends ChangeNotifier { // Controllador de overlay
  bool visible = true;
  void show() {
    visible = true;
    notifyListeners();
  }

  void hide() {
    visible = false;
    notifyListeners();
  }

  void toggle() {
    visible = !visible;
    notifyListeners();
  }
}