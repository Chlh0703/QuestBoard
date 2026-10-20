import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quest_board/services/overlay_controller.dart';
import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../services/overlay_quest_service.dart';
import '../services/overlay_service.dart';
import '../services/window_service.dart';
import '../widgets/overlay_quest_list.dart';


class QuestOverlay extends StatefulWidget { // Caso de stateful ya que hay dadas guardadas en esta "imagen" por la que esta imagen cambia segun x situacion

  final OverlayQuestService overlayQuestService;
  final OverlayController overlayController;

  const QuestOverlay({
    super.key,
    required this.overlayQuestService,
    required this.overlayController,
  });

  @override
  State<QuestOverlay> createState() => _QuestOverlayState();
// Override de createState().
// Flutter llama a esta funcion cuando crea el StatefulWidget.
// Debe devolver una instancia de la clase State asociada,
// que contendrá los datos mutables y la lógica que puede cambiar
// durante la vida del widget (timers, animaciones, variables, etc.).

}

class _QuestOverlayState extends State<QuestOverlay> {
  final GlobalKey _dragHandleKey = GlobalKey();
  Timer? _hideTimer; // instanciador del timer
  late VoidCallback _overlayListener;

  @override
  void initState() {
    super.initState();
    _startHideTimer();

    _overlayListener = () async {
      if (widget.overlayController.visible) {
        _startHideTimer(); // al escuchar que se ha activado, inicia timer tambien
      }
      setState(() {}); // Reset de estado
    };

    widget.overlayController.addListener(_overlayListener);
  }

  void _startHideTimer() {
    _hideTimer?.cancel(); // Cancela lo pendiente del timer
    _hideTimer = Timer( // Aqui es donde define cuanto dura y que hace
      const Duration(seconds: 3),
          () async {
        widget.overlayController.hide();
      },
    );
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  Future<void> _toggleTask(QuestModel quest, TaskModel task) async {
    await WindowService.sendToMain(
      "toggleTask",
      {
        "questId": quest.id,
        "taskId": task.id,
      },
    );
  }

  @override
  void dispose() { // Funcion para detruir la widget al apagar
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.overlayQuestService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Listener(
            child: MouseRegion(
              onEnter: (_) => _cancelHideTimer(),
              onExit: (_) => _startHideTimer(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.overlayController.visible
                          ? Colors.grey.withValues(alpha: 0.55)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.overlayController.visible
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                key: _dragHandleKey,
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.drag_indicator,
                                      color: Colors.white70,
                                      size: 20,
                                    ),

                                    SizedBox(width: 6),

                                    Text(
                                      "BOARD",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Botón apra reabrir main menu
                            IconButton(
                              onPressed: () {
                                WindowService.sendToMain("showMainWindow", null);
                              },
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                              tooltip: "Open QuestBoard",
                            ),
                          ],
                        ),
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                tabs: const [
                                  Tab(text: 'P'),
                                  Tab(text: 'S'),
                                  Tab(text: 'R'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 160,
                                child: TabBarView(
                                  children: [
                                    OverlayQuestList(
                                      quests: widget.overlayQuestService.quests.where((x) => x.classification == 1).toList(),
                                      onTaskTap: _toggleTask,
                                    ),
                                    OverlayQuestList(
                                      quests: widget.overlayQuestService.quests.where((x) => x.classification == 2).toList(),
                                      onTaskTap: _toggleTask,
                                    ),
                                    OverlayQuestList(
                                      quests: widget.overlayQuestService.quests.where((x) => x.classification == 3).toList(),
                                      onTaskTap: _toggleTask,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}