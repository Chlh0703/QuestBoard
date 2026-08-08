import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quest_board/services/overlay_quest_service.dart';

import 'models/quest_model.dart';
import 'services/quest_service.dart';
import 'services/overlay_controller.dart';
import 'services/window_service.dart';
import 'services/hotkey_service.dart';
import 'apps/quest_board_app.dart';
import 'apps/overlay_app.dart';


late final QuestService questService; // Late es basicamente un "prometo que tendrá valor" xD
late final OverlayQuestService overlayQuestService;
final overlayController = OverlayController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(QuestModelAdapter());
  await Hive.openBox<QuestModel>("quests");

  questService = QuestService();
  await questService.initialize();
  print("inside main $questService.quests");
  overlayQuestService = OverlayQuestService(questService.quests);

  // Get the current window controller
  final windowController = await WindowController.fromCurrentEngine();
  final args = windowController.arguments;
  final isOverlay = args.contains("overlay");


  if (!isOverlay) {
    await HotkeyService.initialize(
      showOverlay: WindowService.showOverlay,
    );
    await WindowService.setupMainWindow();
    await WindowService.createOverlayWindow();
    await WindowService.initializeMainReceiver(questService);
  } else if (isOverlay) {
    await WindowService.initializeOverlayReceiver(
      overlayController,
      overlayQuestService,
    );
  }

  runApp(
    isOverlay
        ? OverlayApp(overlayQuestService: overlayQuestService, overlayController: overlayController)
        : QuestBoardApp(questService: questService),
  );
}