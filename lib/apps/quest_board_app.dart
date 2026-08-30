import 'package:flutter/material.dart';
import 'package:quest_board/services/player_service.dart';

import '../screens/home_screen.dart';
import '../services/quest_service.dart';

class QuestBoardApp extends StatelessWidget {
  final QuestService questService;
  final PlayerService playerService;

  const QuestBoardApp({
    super.key,
    required this.questService,
    required this.playerService
  });



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        questService: questService,
        playerService: playerService,
      ),
    );
  }
}