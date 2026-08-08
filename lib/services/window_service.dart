import 'package:flutter/services.dart';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:quest_board/services/quest_service.dart';
import 'package:window_manager/window_manager.dart';
import '../models/quest_model.dart';
import 'overlay_controller.dart';
import 'overlay_quest_service.dart';


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
    await _overlayWindow?.invokeMethod("hideOverlay");
  }


  static Future<void> initializeMainReceiver(QuestService questService) async {
    final controller = await WindowController.fromCurrentEngine();
    await controller.setWindowMethodHandler(
          (MethodCall call) async {
        switch (call.method) {
          case "toggleQuest":
            final quest = QuestModel.fromMap(
              Map<String, dynamic>.from(call.arguments),
            );
            await questService.updateQuest(quest.id, changeCompletion: true);
            break;
          case "createQuest":
            print("creating quest in main");
            break;
          case "updateQuest":
            print("updating quest in main");
            break;
          case "deleteQuest":
            print("deleting quest in main");
            break;
          default:
            return null;
        }
        return null;
      },
    );
  }

  static Future<void> initializeOverlayReceiver(OverlayController overlayController, OverlayQuestService overlayQuestService,) async {
    final controller = await WindowController.fromCurrentEngine();
    await controller.setWindowMethodHandler(
          (MethodCall call) async {
        switch (call.method) {
          case "showOverlay":
            overlayController.show();
            break;
          case "hideOverlay":
            overlayController.hide();
            break;
          case "questsChanged":
            final data = call.arguments as List;
            final quests = data
                .cast<Map>()
                .map((e) => QuestModel.fromMap(
              Map<String, dynamic>.from(e),
            ))
                .toList();
            overlayQuestService.replaceAll(quests);
            break;
          default:
            return null;
        }
        return null;
      },
    );
  }

  static Future<void> sendToMain(
      String method,
      dynamic arguments,
      ) async {
    final windows = await WindowController.getAll();

    for (final window in windows) {
      if (!window.arguments.contains("overlay")) {
        await window.invokeMethod(
          method,
          arguments,
        );
        break;
      }
    }
  }

  static Future<void> sendQuestsToOverlay(
      List<QuestModel> quests,
      ) async {
    final data = quests
        .map((q) => q.toMap())
        .toList();

    await _overlayWindow?.invokeMethod(
      "questsChanged",
      data,
    );
  }

}