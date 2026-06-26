import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home_screen.dart';
import 'services/quest_service.dart';
import 'models/quest.dart';
import 'services/overlay_controller.dart';

final questService = QuestService();
final overlayController = OverlayController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    QuestBoardApp(
      questService: questService,
    ),
  );
}

class QuestBoardApp extends StatelessWidget {
  final QuestService questService;

  const QuestBoardApp({
    super.key,
    required this.questService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        questService: questService,
      ),
    );
  }
}