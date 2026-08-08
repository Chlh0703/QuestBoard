import 'package:flutter/material.dart';
import 'package:quest_board/services/quest_service.dart';

import '../screens/quest_overlay.dart';
import '../services/overlay_controller.dart';
import '../services/overlay_quest_service.dart';

class OverlayApp extends StatefulWidget {

  final OverlayQuestService overlayQuestService;
  final OverlayController overlayController;

  const OverlayApp({
    super.key,
    required this.overlayQuestService,
    required this.overlayController,
  });

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuestOverlay(
        overlayQuestService: widget.overlayQuestService,
        overlayController: widget.overlayController,
      ),
    );
  }
}