import 'package:quest_board/models/player_statistics.dart';

class AchievementModel {
  // Identificador único del achievement.
  final String id;

  // Información que verá el jugador.
  final String title;
  final String description;

  // Progreso necesario para desbloquearlo.
  final int target;

  // Función que obtiene el progreso desde las estadísticas.
  final int Function(PlayerStatistics statistics) progressGetter;

  // Estado del achievement.
  bool unlocked;
  DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.progressGetter,
    this.unlocked = false,
    this.unlockedAt,
  });

  // Obtiene el progreso actual.
  int getProgress(PlayerStatistics statistics) {
    final progress = progressGetter(statistics);

    return progress < 0 ? 0 : progress;
  }

  // Limita el progreso mostrado al objetivo del achievement.
  int getDisplayedProgress(PlayerStatistics statistics) {
    final progress = getProgress(statistics);

    return progress > target ? target : progress;
  }

  // Calcula el porcentaje de progreso entre 0.0 y 1.0.
  double getProgressPercentage(PlayerStatistics statistics) {
    if (target <= 0) return 1.0;

    return (getProgress(statistics) / target).clamp(0.0, 1.0);
  }

  // Comprueba si se cumplen las condiciones para desbloquearlo.
  bool canUnlock(PlayerStatistics statistics) {
    if (unlocked) return false;

    return getProgress(statistics) >= target;
  }

  // Desbloquea el achievement.
  void unlock() {
    if (unlocked) return;

    unlocked = true;
    unlockedAt = DateTime.now();
  }
}