import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'apps/quest_board_app.dart';
import 'apps/overlay_app.dart';
import 'services/quest_service.dart';
import 'models/quest.dart';
import 'services/overlay_controller.dart';
import 'services/window_service.dart';


final questService = QuestService();
final overlayController = OverlayController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get the current window controller
  final windowController = await WindowController.fromCurrentEngine();
  final args = windowController.arguments;
  final isOverlay = args.contains("overlay");

  if (!isOverlay) {
    await WindowService.setupMainWindow();
    await WindowService.createOverlayWindow();
  }

  // Datos de prueba
  questService.addQuest(
    Quest(
      title: "Acabar Benchmark",
      description: "Ya va siendo hora",
    ),
  );

  questService.addQuest(
    Quest(
      title: "Crear Overlay",
      description: "Que es un overlay???",
      completed: true,
    ),
  );

  runApp(
    isOverlay
        ? OverlayApp(questService: questService)
        : QuestBoardApp(questService: questService),
  );
}