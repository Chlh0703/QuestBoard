import 'package:flutter/material.dart';
import '../models/quest.dart';
import 'quest_card.dart';

class QuestList extends StatelessWidget { // Stateless widget: dadas no se guardan aqui esto es escencialmente una "imagen"
  final Function(Quest) onQuestTap;
  final List<Quest> quests;

  const QuestList({
    super.key, // La "id" de esta classe
    required this.quests,
    required this.onQuestTap,
  });

  @override
  Widget build(BuildContext context) { // Como se construye la "imagen"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // El axis, en este caso pegado a la izquierda
      children: quests
          .map((quest) => QuestCard(quest: quest, onTap: () => onQuestTap(quest)))
          .toList(),
    );
  }
}