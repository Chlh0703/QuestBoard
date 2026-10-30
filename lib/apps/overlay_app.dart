import 'package:flutter/material.dart';

import '../screens/quest_overlay.dart';
import '../controllers/overlay_controller.dart';
import '../services/overlay_quest_service.dart';

class OverlayApp extends StatelessWidget {

  final OverlayQuestService overlayQuestService;
  final OverlayController overlayController;

  const OverlayApp({
    super.key,
    required this.overlayQuestService,
    required this.overlayController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuestOverlay(
        overlayQuestService: overlayQuestService,
        overlayController: overlayController,
      ),
    );
  }
}