import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';
import 'overlay_controller.dart';


class WindowService {

  static WindowController? _overlayWindow;

  static Future<void> setupMainWindow() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(900, 650),
      center: true,
      title: "QuestBoard",
    );

    await windowManager.waitUntilReadyToShow(
      windowOptions,
          () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  static Future<void> createOverlayWindow() async {
    _overlayWindow = await WindowController.create(const WindowConfiguration(arguments: '{"window":"overlay"}',),);
    await _overlayWindow!.show();
  }

  static Future<void> showOverlay() async {
    await _overlayWindow?.invokeMethod("showOverlay",);
  }

  static Future<void> hideOverlay() async {
    print(_overlayWindow);
    print("intentando hiddear primer paso");
    await _overlayWindow?.invokeMethod("hideOverlay");
  }

  static Future<void> initializeOverlayReceiver(OverlayController overlayController) async {
    final controller = await WindowController.fromCurrentEngine();
    await controller.setWindowMethodHandler(
          (MethodCall call) async {
        switch (call.method) {
          case "showOverlay":
            overlayController.show();
            break;
          case "hideOverlay":
            print("intentando hiddear segundo paso");
            overlayController.hide();
            break;
          default:
            return null;
        }
        return null;
      },
    );
  }
}