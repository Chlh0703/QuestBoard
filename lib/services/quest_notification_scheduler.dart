import '../models/quest_model.dart';
import 'notification_service.dart';

/// Aplica las reglas de negocio que determinan qué recordatorios de quests
/// deben estar registrados en el sistema operativo.
class QuestNotificationScheduler {
  QuestNotificationScheduler(this._notificationsService);

  final NotificationService _notificationsService;

  // Espacio reservado para avisos de quests. No se cancelan avisos de otros
  // tipos que también puedan usar flutter_local_notifications.
  static const int _questIdStart = 1000000000;
  static const int _questIdMask = 0x3fffffff;

  int _notificationIdFor(QuestModel quest) {
    // FNV-1a sobre el UUID: determinista entre ejecuciones, a diferencia de
    // String.hashCode. El resultado queda dentro del rango reservado.
    var hash = 0x811c9dc5;
    for (final codeUnit in quest.id.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return _questIdStart + (hash & _questIdMask);
  }

  void _validateNoIdCollisions(Iterable<QuestModel> quests) {
    final ownersByNotificationId = <int, String>{};

    for (final quest in quests) {
      final notificationId = _notificationIdFor(quest);
      final previousOwner = ownersByNotificationId[notificationId];

      if (previousOwner != null) {
        throw StateError(
          'Colisión de ID de notificación entre las quests '
          '"$previousOwner" y "${quest.id}".',
        );
      }

      ownersByNotificationId[notificationId] = quest.id;
    }
  }

  Future<void> syncQuest(
    QuestModel quest, {
    required Iterable<QuestModel> currentQuests,
  }) async {
    _validateNoIdCollisions(currentQuests);

    final notificationId = _notificationIdFor(quest);
    await _notificationsService.cancelNotification(notificationId);

    final dueDate = quest.dueDate;
    if (dueDate == null || quest.completed) return;

    await _notificationsService.scheduleNotification(
      id: notificationId,
      title: 'Quest pendiente',
      body: '「${quest.title}」 vence ahora.',
      scheduledDate: dueDate,
    );
  }

  /// Reconstrucció en la inicializació de la app
  Future<void> syncAll(List<QuestModel> quests) async {
    _validateNoIdCollisions(quests);

    final pending = await _notificationsService.pendingNotificationRequests();
    for (final request in pending) {
      if (_isQuestNotificationId(request.id)) {
        await _notificationsService.cancelNotification(request.id);
      }
    }

    for (final quest in quests) {
      await syncQuest(quest, currentQuests: quests);
    }
  }

  Future<void> cancelQuest(QuestModel quest) => _notificationsService.cancelNotification(_notificationIdFor(quest));

  bool _isQuestNotificationId(int id) => id >= _questIdStart && id <= _questIdStart + _questIdMask;
}
