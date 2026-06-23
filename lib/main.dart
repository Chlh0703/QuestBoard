import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'models/quest.dart';
import 'screens/quest_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

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
          completed: false,
        ),
        Quest(
          title: "Crear Overlay",
          completed: false,
        ),
        Quest(
          title: "Configurar Flutter",
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