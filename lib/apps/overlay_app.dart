import 'package:flutter/material.dart';

import '../screens/quest_overlay.dart';
import '../services/quest_service.dart';

class OverlayApp extends StatelessWidget {
  final QuestService questService;

  const OverlayApp({
    super.key,
    required this.questService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuestOverlay(
        questService: questService,
      ),
    );
  }
}