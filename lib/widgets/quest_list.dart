import 'package:flutter/material.dart';
import '../models/quest_model.dart';
import 'quest_card.dart';

class QuestList extends StatelessWidget { // Stateless widget: dadas no se guardan aqui esto es escencialmente una "imagen"
  final Function(QuestModel) onToggleCompletion;
  final Function(QuestModel) onQuestEdit;
  final Function(QuestModel) onQuestDelete;
  final Function(QuestModel) onTogglePause;

  final List<QuestModel> quests;

  const QuestList({
    super.key, // La "id" de esta classe
    required this.quests,
    required this.onToggleCompletion,
    required this.onQuestEdit,
    required this.onQuestDelete,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) { // Como se construye la "imagen"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // El axis, en este caso pegado a la izquierda
      children:
        quests.map((quest) => QuestCard(
          quest: quest,
          onToggleCompletion: () => onToggleCompletion(quest),
          onEdit: () => onQuestEdit(quest),
          onDelete: () => onQuestDelete(quest),
          onArchive: () { print("archiving");}, //TODO: Gotta finish this part
          onTogglePause: () => onTogglePause(quest),
        )).toList(),

    );
  }
}