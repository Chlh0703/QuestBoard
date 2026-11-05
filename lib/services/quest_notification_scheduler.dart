import '../models/quest_model.dart';
import '../models/task_model.dart';
import 'notification_service.dart';

/// Mantiene sincronizados los recordatorios de las tareas de cada quest.
class QuestNotificationScheduler {
  final NotificationService _notificationsService;
  bool _enabled;

  QuestNotificationScheduler(
    this._notificationsService, {
      this._enabled = true,
      });

  // Id Start hace que empiece dejando margen a otras notis,
  // Mientras que la Mask es basicamente que le hacen un AND y fuerzan que no sea tan grande
  static const int _questIdStart = 1000000000;
  static const int _questIdMask = 0x3fffffff;
  static const String _payloadPrefix = 'quest-task-reminder:';

  int _notificationIdForTask(QuestModel quest, TaskModel task) {
    // Hash proveniente de FNV-1a
    final taskKey = '${quest.id}:${task.id}';
    var hash = 0x811c9dc5;

    for (final codeUnit in taskKey.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return _questIdStart + (hash & _questIdMask);
  }

  Future<void> setEnabled(bool enabled, List<QuestModel> quests) async {
    _enabled = enabled;
    await syncAll(quests);
  }

  String _payloadForQuest(QuestModel quest) => '$_payloadPrefix${quest.id}:';

  String _payloadForTask(QuestModel quest, TaskModel task) =>
      '${_payloadForQuest(quest)}${task.id}';

  void _validateNoIdCollisions(Iterable<QuestModel> quests) {
    final ownersByNotificationId = <int, String>{};

    for (final quest in quests) {
      for (final task in quest.tasks) {
        final notificationId = _notificationIdForTask(quest, task);
        final taskKey = '${quest.id}:${task.id}';
        final previousOwner = ownersByNotificationId[notificationId];

        if (previousOwner != null && previousOwner != taskKey) {
          throw StateError(
            'Colisión de ID de notificación entre las tareas '
            '"$previousOwner" y "$taskKey".',
          );
        }

        ownersByNotificationId[notificationId] = taskKey;
      }
    }
  }

  Future<void> syncQuest(
    QuestModel quest, {
    required Iterable<QuestModel> currentQuests,
  }) async {
    _validateNoIdCollisions(currentQuests);
    await _cancelRemindersForQuest(quest);
    if (!_enabled) return;
    await _scheduleRemindersForQuest(quest);

  }

  /// Reconstruye los recordatorios de tareas al iniciar la aplicación.
  Future<void> syncAll(List<QuestModel> quests) async {
    _validateNoIdCollisions(quests);
    await cancelAll();

    if (!_enabled) return;

    for (final quest in quests) {
      await _scheduleRemindersForQuest(quest);
    }
  }

  Future<void> cancelAll() async {
    final pending = await _notificationsService.pendingNotificationRequests();

    for (final request in pending) {
      if (_isQuestNotificationId(request.id)) {
        await _notificationsService.cancelNotification(request.id);
      }
    }
  }

  Future<void> cancelQuest(QuestModel quest) => _cancelRemindersForQuest(quest);

  Future<void> _cancelRemindersForQuest(QuestModel quest) async {
    final payloadPrefix = _payloadForQuest(quest);
    final pending = await _notificationsService.pendingNotificationRequests();

    for (final request in pending) {
      if (request.payload?.startsWith(payloadPrefix) ?? false) {
        await _notificationsService.cancelNotification(request.id);
      }
    }
  }

  Future<void> _scheduleRemindersForQuest(QuestModel quest) async {
    if (quest.completed || quest.reminderMinutesBefore < 0) {
      return;
    }

    for (final task in quest.tasks) {
      final taskDueDate = task.dueDate;
      if (task.completed || taskDueDate == null) continue;

      final reminderDate = taskDueDate.subtract(
        Duration(minutes: quest.reminderMinutesBefore),
      );

      await _notificationsService.scheduleNotification(
        id: _notificationIdForTask(quest, task),
        title: 'Tarea próxima a vencer',
        body: '${quest.title}: ${task.title}',
        scheduledDate: reminderDate,
        payload: _payloadForTask(quest, task),
      );
    }
  }

  bool _isQuestNotificationId(int id) =>  id >= _questIdStart && id <= _questIdStart + _questIdMask;
}
