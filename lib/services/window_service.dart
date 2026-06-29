import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:quest_board/services/overlay_service.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
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

  static Future<void> setupOverlayWindow() async {
  }

  static Future<void> createOverlayWindow() async {
    final overlay = await WindowController.create(
      const WindowConfiguration(
        arguments: '{"window":"overlay"}',
      ),
    );
    await overlay.show();
  }

}