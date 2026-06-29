import 'package:flutter/material.dart';

import '../models/quest.dart';

class QuestCard extends StatelessWidget { // La gracia de stateless esque aqui no se guardan datos, si se guardaran seria stateful
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final Quest quest;
  const QuestCard({
    super.key, // Todos tienen una key, eso es para identificar, de alguna forma es parecido a una biblioteca
    required this.quest,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
            Row(
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
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                )
              ]
            ),
            Padding(
              padding: const EdgeInsets.only(left:20),
              child: Text(
                quest.description,
                style: TextStyle(
                  color:
                  quest.completed ? Colors.green : Colors.white,
                )
              ),
            )
          ]
        ),
      ),
    );
  }
}