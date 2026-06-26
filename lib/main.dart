import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'models/quest.dart';
import 'screens/quest_overlay.dart';
import 'services/hotkey_service.dart';
import 'services/overlay_controller.dart';

final overlayController = OverlayController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await HotkeyService.initialize(
    showOverlay: () { // Definir que showOverlay será X funcion
      overlayController.show();
    },
  );

  const windowOptions = WindowOptions(
    size: Size(350, 600),
    center: true,
    title: "QuestBoard",
    alwaysOnTop: true,
    backgroundColor: Colors.transparent,
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
        () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(
    QuestBoardApp(
      quests: [
        Quest(
          title: "Acabar Benchmark",
          description: "Ya va siendo hora",
          completed: false,
        ),
        Quest(
          title: "Crear Overlay",
          description: "Que es un overlay???",
          completed: true,
        ),
        Quest(
          title: "Configurar Flutter",
          description: ":)))",
          completed: true,
        ),
      ],
    ),
  );
}

class QuestBoardApp extends StatelessWidget {
  final List<Quest> quests;

  const QuestBoardApp({
    super.key,
    required this.quests,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuestOverlay(
        quests: quests,
      ),
    );
  }
}