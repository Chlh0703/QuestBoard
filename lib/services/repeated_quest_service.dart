import '../models/quest_model.dart';

class RepeatedQuestService {
  static bool shouldArchive(QuestModel quest, DateTime now) {
    return quest.repeatEnd != null &&
        quest.repeatEnd!.isBefore(now);
  }

  static int getMissedIntervals(QuestModel quest, DateTime now) {
    if (quest.startDate == null || quest.dueDate == null) {
      return 0;
    }

    final interval = quest.dueDate!.difference(quest.startDate!);

    if (interval.inDays <= 0) {
      return 0;
    }

    final intervalsPassed =
        now.difference(quest.startDate!).inDays ~/ interval.inDays;

    return intervalsPassed > 0 ? intervalsPassed : 0;
  }

  static void updateRepeatDates(QuestModel quest, int intervalsPassed) {
    final interval = quest.dueDate!.difference(quest.startDate!);
    quest.setStartDate(
      quest.startDate!.add(interval * intervalsPassed),
    );

    quest.setDueDate(
      quest.dueDate!.add(interval * intervalsPassed),
    );
  }
}