import 'package:flutter/material.dart';

import '../models/quest_model.dart';

class OverlayQuestCard extends StatelessWidget { // La gracia de stateless esque aqui no se guardan datos, si se guardaran seria stateful
  final VoidCallback onTap;
  final QuestModel quest;
  const OverlayQuestCard({
    super.key, // Todos tienen una key, eso es para identificar, de alguna forma es parecido a una biblioteca
    required this.quest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {  // Build es basicamente decir como se tiene que construir la classe
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Padding: espacio, child: hijo, dado este espacio poner este hijo
      child: GestureDetector( // Deteccion de tap
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.completed
                  ? "■ ${quest.title}"
                  : "□ ${quest.title}",
              style: TextStyle(
                color:
                quest.completed ? Colors.green : Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:20),
              child: Text(
                  "REWARD: ${quest.experienceReward} EXP",
                style: TextStyle(
                  color: quest.completed ? Colors.green : Colors.white,
                  decoration: quest.completed ? TextDecoration.lineThrough : TextDecoration.none,
                )
              ),
            )
          ]
        ),
      ),
    );
  }
}