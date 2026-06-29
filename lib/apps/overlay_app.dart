import 'package:flutter/material.dart';
import 'package:quest_board/services/quest_service.dart';

import '../screens/quest_overlay.dart';
import '../services/overlay_controller.dart';
import '../services/window_service.dart';

class OverlayApp extends StatefulWidget {

  final QuestService questService;
  final OverlayController overlayController;

  const OverlayApp({
    super.key,
    required this.questService,
    required this.overlayController,
  });

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {

  @override
  void initState() {
    super.initState();

    WindowService.initializeOverlayReceiver(widget.overlayController);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuestOverlay(
        questService: widget.questService,
      ),
    );
  }
}