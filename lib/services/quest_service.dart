import '../models/quest.dart';

class QuestService {
  final List<Quest> quests = [];

  void addQuest(Quest quest){
    quests.add(quest);
  }

  void removeQuest(Quest quest){
    if(quests.contains(quest)){
      quests.remove(quest);
    }
  }

  void updateQuest(Quest quest, String newTitle, String newDescription){
    if(!quests.contains(quest)){
      return ; // TODO: Return error
    }
    Quest updatedQuest = Quest(
      title: newTitle,
      description: newDescription,
      completed: quest.completed
    );
  }
}