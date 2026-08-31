import 'package:flutter/material.dart';

import '../models/quest_model.dart';

class QuestCard extends StatelessWidget { // La gracia de stateless esque aqui no se guardan datos, si se guardaran seria stateful
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  final QuestModel quest;
  const QuestCard({
    super.key, // Todos tienen una key, eso es para identificar, de alguna forma es parecido a una biblioteca
    required this.quest,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {  // Build es basicamente decir como se tiene que construir la classe
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte de la quest que responde al onTap
          GestureDetector(
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
                        color: quest.completed
                            ? Colors.green
                            : Colors.white,
                        decoration: quest.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
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
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "REWARD: ${quest.experienceReward} EXP",
                    style: TextStyle(
                      color: quest.completed ? Colors.green : Colors.white,
                      decoration: quest.completed ? TextDecoration.lineThrough  : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botones FUERA del GestureDetector
          if(quest.completed)
              ElevatedButton(
            onPressed: onArchive,
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
  }
}