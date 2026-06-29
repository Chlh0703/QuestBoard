import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../services/quest_service.dart';

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