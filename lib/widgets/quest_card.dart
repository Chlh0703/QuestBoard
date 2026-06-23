import 'package:flutter/material.dart';

import '../models/quest.dart';

class QuestCard extends StatelessWidget { // La gracia de stateless esque aqui no se guardan datos, si se guardaran seria stateful
  final Quest quest;
  const QuestCard({
    super.key, // Todos tienen una key, eso es para identificar, de alguna forma es parecido a una biblioteca
    required this.quest,
  });

  @override
  Widget build(BuildContext context) {  // Build es basicamente decir como se tiene que construir la classe
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Padding: espacio, child: hijo, dado este espacio poner este hijo
      child: Text(
        quest.completed
            ? "■ ${quest.title}"
            : "□ ${quest.title}",
        style: TextStyle(
          color:
          quest.completed
              ? Colors.green
              : Colors.white,
        ),
      ),
    );
  }
}