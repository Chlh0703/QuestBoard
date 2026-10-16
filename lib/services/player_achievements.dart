import 'package:flutter/foundation.dart';

import '../models/achievement_model.dart';
import '../models/player_statistics.dart';
import 'storage_service.dart';

class PlayerAchievements extends ChangeNotifier {
  // Estadísticas utilizadas para comprobar los achievements.
  final PlayerStatistics statistics;

  // Lista de todos los achievements registrados.
  final List<AchievementModel> _achievements = [];

  final StorageService _storageService = StorageService();

  // Constructor.
  PlayerAchievements({
    required this.statistics,
  }) {
    _registerAchievements();
  }

  // Permite consultar la lista sin modificarla desde fuera.
  List<AchievementModel> get achievements =>
      List.unmodifiable(_achievements);

  // Devuelve únicamente los achievements desbloqueados.
  List<AchievementModel> get unlockedAchievements =>
      List.unmodifiable(
        _achievements.where((achievement) => achievement.unlocked),
      );

  // Devuelve únicamente los achievements pendientes.
  List<AchievementModel> get lockedAchievements =>
      List.unmodifiable(
        _achievements.where((achievement) => !achievement.unlocked),
      );

  // Número total de achievements.
  int get totalAchievements => _achievements.length;

  // Número de achievements desbloqueados.
  int get unlockedCount =>
      _achievements.where((achievement) => achievement.unlocked).length;

  // Porcentaje global de achievements completados.
  double get completionPercentage {
    if (_achievements.isEmpty) return 0.0;

    return unlockedCount / totalAchievements;
  }

  // ============================================================
  // 1. REGISTRAR ACHIEVEMENTS
  // ============================================================

  void _registerAchievements() {
    _achievements.addAll([
      AchievementModel(
        id: 'first_quest',
        title: 'First Steps',
        description: 'Complete your first quest.',
        target: 1,
        progressGetter: (statistics) => statistics.completedQuestsByType.fold(0, (total, value) => total + value),
      ),

      AchievementModel(
        id: 'quest_collector',
        title: 'Quest Collector',
        description: 'Complete 10 quests.',
        target: 10,
        progressGetter: (statistics) => statistics.completedQuestsByType.fold(0, (total, value) => total + value),
      ),

      AchievementModel(
        id: 'quest_master',
        title: 'Quest Master',
        description: 'Complete 50 quests.',
        target: 50,
        progressGetter: (statistics) => statistics.completedQuestsByType.fold(0, (total, value) => total + value),
      ),
    ]);
  }

  // ============================================================
  // 2. INICIALIZAR EL SISTEMA
  // ============================================================

  Future<void> initialize() async {
    // Recupera los estados guardados de los logros.
    for (final achievement in _achievements) {
      final savedState =
      _storageService.loadAchievementState(achievement.id);

      if (savedState == null) continue;

      achievement.unlocked = savedState['unlocked'] == true;

      final savedDate = savedState['unlockedAt'];

      if (savedDate is String) {
        achievement.unlockedAt = DateTime.tryParse(savedDate);
      }
    }

    notifyListeners();

    // Comprueba si hay logros que deban desbloquearse.
    await checkAchievements();
  }

  // ============================================================
  // 3. COMPROBAR ACHIEVEMENTS
  // ============================================================

  Future<void> checkAchievements() async {
    bool hasChanges = false;

    for (final achievement in _achievements) {
      // Si ya está desbloqueado, no hace falta comprobarlo.
      if (achievement.unlocked) continue;

      // Si cumple las condiciones, lo desbloqueamos.
      if (achievement.canUnlock(statistics)) {
        achievement.unlock();

        // Guardamos el estado en Hive.
        await _storageService.saveAchievementState(
          achievement.id,
          unlocked: achievement.unlocked,
          unlockedAt: achievement.unlockedAt,
        );

        hasChanges = true;
      }
    }

    // Actualizamos la interfaz solo si ha habido cambios.
    if (hasChanges) {
      notifyListeners();
    }
  }
}