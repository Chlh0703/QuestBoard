import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:quest_board/models/task_model.dart';
import 'package:quest_board/services/player_achievements.dart';
import 'package:quest_board/services/player_service.dart';
import 'package:quest_board/services/quest_overlay_notifier.dart';
import 'package:quest_board/services/repeated_quest_service.dart';

import '../repositories/quest_repository.dart';
import '../models/quest_model.dart';

class QuestService extends ChangeNotifier {
  final QuestOverlayNotifier _overlayNotifier;
  final QuestRepository _questRepository;
  final PlayerService _playerService;
  final PlayerAchievements _playerAchievements;

  final List<QuestModel> _quests = [];
  final List<QuestModel> _archivedQuests = [];

  Timer? _repeatTimer;

  QuestService(
    this._playerService,
    this._playerAchievements,
    {
      required this._overlayNotifier,
      required this._questRepository,
    });

  List<QuestModel> get quests => List.unmodifiable(_quests);
  List<QuestModel> get archivedQuests => List.unmodifiable(_archivedQuests);

  Future<void> initialize() async {
    await loadQuests();
    await _updateRepeatedQuests();
    _repeatTimer = Timer.periodic(const Duration(minutes: 1),
          (_) async {
        await _updateRepeatedQuests();
      },
    );
  }

  Future<void> loadQuests() async {
    _quests..clear()..addAll(await _questRepository.getAll());
    _archivedQuests..clear()..addAll(await _questRepository.getArchived());
    notifyListeners();
  }

  Future<void> syncOverlay() async {
    await _overlayNotifier.questsChanged(
      List.unmodifiable(_quests),
    );
  }

  Future<void> _updateRepeatedQuests() async {
    final now = DateTime.now();

    for (final quest in _quests.where((q) => q.classification == 3).toList()) {
      if (quest.startDate == null || quest.dueDate == null) {
        continue;
      }

      if (RepeatedQuestService.shouldArchive(quest, now)){
        await archiveQuest(quest);
        continue;
      }

      final intervalsPassed = RepeatedQuestService.getMissedIntervals(quest, now);

      if (intervalsPassed == 0) continue;

      _playerService.takeDamage(intervalsPassed);

      RepeatedQuestService.updateRepeatDates(quest, intervalsPassed,);
    }
  }

  Future<void> _saveAndSync() async {
    await _questRepository.saveAll(_quests);
    await _questRepository.saveArchived(_archivedQuests);
    await _playerService.saveAndSync();

    await syncOverlay();
    notifyListeners();
  }

  Future<void> addQuest(QuestModel quest) async {
    _quests.add(quest);
    _playerService.statistics.questsCreated++;
    await _saveAndSync();
  }

  Future<void> archiveQuest(QuestModel quest) async {
    if(_quests.contains(quest)){
      final questCopy = QuestModel.fromMap(quest.toMap());
      _archivedQuests.add(questCopy);
      _quests.remove(quest);
      await _saveAndSync();
    }
  }

  Future<void> restoreQuest(QuestModel quest) async {
    if(_archivedQuests.contains(quest)){
      final questCopy = QuestModel.fromMap(quest.toMap());
      _quests.add(questCopy);
      _archivedQuests.remove(quest);
      await _saveAndSync();
    }
  }

  Future<void> removeArchivedQuest(QuestModel quest) async {
    if(_archivedQuests.remove(quest)){
      await _saveAndSync();
    }
  }

  Future<void> updateQuest(String questId, {
        // Quest
        String? newTitle, int? newExpReward, bool togglePause = false, int? newClassification, DateTime? newDueDate, DateTime? newStartDate, DateTime? newRepeatEnd,
        // Tasks
        List<TaskModel>? newTasks, String? taskId,
      }) async {
    final quest = _quests.cast<QuestModel?>().firstWhere(
          (q) => q?.id == questId,
      orElse: () => null,
    );

    if (quest == null) return;

    // Quest
    if (newTitle != null) quest.setTitle(newTitle);

    if (newExpReward != null) quest.setExperienceReward(newExpReward);

    if (togglePause) quest.togglePaused();

    if (newClassification != null) quest.setClassification(newClassification);

    if (newDueDate != null) {
      for (final task in quest.tasks) {
        if (task.dueDate != null && task.dueDate!.isAfter(newDueDate)) task.setDueDate(newDueDate);
      }
      quest.setDueDate(newDueDate);
    }

    if (newStartDate != null) quest.setStartDate(newStartDate);
    
    if (newRepeatEnd != null && newRepeatEnd.isAfter(quest.dueDate!)) quest.setRepeatEnd(newRepeatEnd);

    // Tasks
    if (newTasks != null) {
      // Reemplazar toda la lista
      quest.setTasks(newTasks);
    } else if (taskId != null) {
      // Modificar una Task concreta
      final completionChanged = quest.taskTapped(taskId,);

      if (completionChanged) {
        if (quest.completed) {
          await _playerService.addExperience(quest.experienceReward);
          if (!quest.paused) quest.togglePaused();
          _playerService.statistics.registerQuestCompleted(quest.classification, true);
        } else {
          await _playerService.addExperience(-quest.experienceReward);
          _playerService.statistics.registerQuestCompleted(quest.classification, false);
        }
      }
    }
    await _saveAndSync();

    await _playerAchievements.checkAchievements();
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }
}