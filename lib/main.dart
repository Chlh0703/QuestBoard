import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:quest_board/controllers/quest_controller.dart';
import 'package:quest_board/repositories/hive_quest_repository.dart';
import 'package:quest_board/services/overlay_quest_service.dart';
import 'package:quest_board/services/player_achievements.dart';
import 'package:quest_board/services/player_service.dart';
import 'package:quest_board/services/storage_service.dart';

import 'services/quest_service.dart';
import 'controllers/overlay_controller.dart';
import 'services/window_service.dart';
import 'services/hotkey_service.dart';
import 'apps/quest_board_app.dart';
import 'apps/overlay_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowController = await WindowController.fromCurrentEngine();
  final isOverlay = windowController.arguments.contains("overlay");

  if (isOverlay) {
    await runOverlayWindow();
  } else {
    await runMainWindow();
  }
}

Future<void> runMainWindow() async {
  final storageService = StorageService();
  await storageService.initialize();
  final questRepository = HiveQuestRepository(storageService);

  // For some test reasons:
  // await questRepository.clearAll();

  final playerService = PlayerService();
  await playerService.initialize();

  final playerAchievements = PlayerAchievements(statistics: playerService.statistics,);
  await playerAchievements.initialize();

  final questService = QuestService(playerService, playerAchievements, overlayNotifier: WindowService(), questRepository: questRepository,);
  await questService.initialize();

  final questController = QuestController(questService);
  await HotkeyService.initialize(showOverlay: WindowService.showOverlay,);

  await WindowService.setupMainWindow();
  await WindowService.initializeMainReceiver(questController);
  await WindowService.createOverlayWindow();

  runApp(
    QuestBoardApp(
      questController: questController,
      playerService: playerService,
      playerAchievements: playerAchievements,
    ),
  );
}



Future<void> runOverlayWindow() async {
  final overlayController = OverlayController();
  final overlayQuestService = OverlayQuestService([]);
  await WindowService.initializeOverlayReceiver(
    overlayController,
    overlayQuestService,
  );
  await WindowService.sendToMain(
    'overlayReady',
    null,
  );
  runApp(
    OverlayApp(
      overlayQuestService: overlayQuestService,
      overlayController: overlayController,
    ),
  );
}