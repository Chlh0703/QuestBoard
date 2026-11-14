import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:quest_board/controllers/quest_controller.dart';
import 'package:quest_board/repositories/hive_quest_repository.dart';
import 'package:quest_board/services/notification_service.dart';
import 'package:quest_board/services/overlay_quest_service.dart';
import 'package:quest_board/services/player_achievements.dart';
import 'package:quest_board/services/player_service.dart';
import 'package:quest_board/services/quest_notification_scheduler.dart';
import 'package:quest_board/services/storage_service.dart';
import 'package:quest_board/services/game_service.dart';

import 'services/quest_service.dart';
import 'services/configuration_service.dart';
import 'controllers/overlay_controller.dart';
import 'services/window_service.dart';
import 'services/overlay_service.dart';
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
  // For some test reasons...
  await storageService.clearDatabase();

  final gameService = GameService(storageService);
  await gameService.initialize();
  // Just wanted to play xD
  gameService.addEnergy(100000);

  final questRepository = HiveQuestRepository(storageService);

  final configurationService = ConfigurationService(storageService);
  final configuration = await configurationService.loadConfiguration();

  HotkeyService.modifierKey = HotkeyService.modifierFromName(configuration.hotkeyModifier);
  HotkeyService.mainKey = HotkeyService.keyFromDebugName(configuration.hotkeyMainKey);
  QuestService.initializeNotificationsEnabled(configuration.notificationsEnabled,);

  final playerService = PlayerService();
  await playerService.initialize();

  final playerAchievements = PlayerAchievements(statistics: playerService.statistics,);
  await playerAchievements.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final notificationScheduler = QuestNotificationScheduler(notificationService);

  final questService = QuestService(
    playerService,
    playerAchievements,
    gameService: gameService,
    overlayNotifier: WindowService(),
    questRepository: questRepository,
    notificationScheduler: notificationScheduler,
  );
  await questService.initialize();

  final questController = QuestController(questService);

  await HotkeyService.initialize(showOverlay: WindowService.showOverlay);

  await WindowService.setupMainWindow();
  await WindowService.initializeMainReceiver(questController);
  await WindowService.createOverlayWindow();
  await OverlayService.setAlwaysOnTop(configuration.alwaysOnTop);

  runApp(
    QuestBoardApp(
      questController: questController,
      playerService: playerService,
      playerAchievements: playerAchievements,
      gameService: gameService,
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
  await WindowService.sendToMain('overlayReady', null);
  runApp(
    OverlayApp(
      overlayQuestService: overlayQuestService,
      overlayController: overlayController,
    ),
  );
}