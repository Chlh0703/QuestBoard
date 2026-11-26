import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:quest_board/controllers/overlay_controller.dart';
import 'package:window_manager/window_manager.dart';
import '../models/quest_model.dart';
import '../models/task_model.dart';
import '../services/overlay_quest_service.dart';
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
    widget.overlayController.removeListener(_overlayListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.overlayQuestService,
      builder: (context, child) {
        final windows = defaultTargetPlatform == TargetPlatform.windows;
        final mac = defaultTargetPlatform == TargetPlatform.macOS;
        final canDragHeader = windows || mac;
        final board = Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
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
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: canDragHeader
                                ? (_) => windowManager.startDragging()
                                : null,
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
                    Expanded(
                      child: DefaultTabController(
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
                            const SizedBox(height: 8),
                            Expanded(
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
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        );
        return MouseRegion(
          onEnter: (_) => _cancelHideTimer(),
          onExit: (_) => _startHideTimer(),
          child: canDragHeader && widget.overlayController.visible
              ? _OverlayResizeBorder(child: board)
              : board,
        );
      },
    );
  }
}

class _OverlayResizeBorder extends StatelessWidget {
  const _OverlayResizeBorder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final windows = defaultTargetPlatform == TargetPlatform.windows;
    const thickness = 15.0;

    Widget handle(ResizeEdge edge, {double? left, double? top, double? right, double? bottom}) {
      final cursor = switch (edge) {
        ResizeEdge.left || ResizeEdge.right => SystemMouseCursors.resizeLeftRight,
        ResizeEdge.top || ResizeEdge.bottom => SystemMouseCursors.resizeUpDown,
        ResizeEdge.topLeft || ResizeEdge.bottomRight =>
          windows ? SystemMouseCursors.resizeUpLeftDownRight : SystemMouseCursors.precise,
        ResizeEdge.topRight || ResizeEdge.bottomLeft =>
          windows ? SystemMouseCursors.resizeUpRightDownLeft : SystemMouseCursors.precise,
      };
      final verticalEdge = edge == ResizeEdge.top || edge == ResizeEdge.bottom;
      return Positioned(
        left: left, right: right, top: top, bottom: bottom,
        width: left == null || right == null ? thickness : null,
        height: top == null || bottom == null ? thickness : null,
        child: MouseRegion(
          cursor: cursor,
          child: windows
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => windowManager.startResizing(edge),
                  onDoubleTap: verticalEdge ? () => windowManager.maximize(vertically: true) : null,
                )
              : null,
        ),
      );
    }

    return Stack(children: [
      child,
      handle(ResizeEdge.left, left: 0, top: thickness, bottom: thickness),
      handle(ResizeEdge.right, right: 0, top: thickness, bottom: thickness),
      handle(ResizeEdge.top, top: 0, left: thickness, right: thickness),
      handle(ResizeEdge.bottom, bottom: 0, left: thickness, right: thickness),
      handle(ResizeEdge.topLeft, top: 0, left: 0),
      handle(ResizeEdge.topRight, top: 0, right: 0),
      handle(ResizeEdge.bottomLeft, bottom: 0, left: 0),
      handle(ResizeEdge.bottomRight, bottom: 0, right: 0),
    ]);
  }
}
