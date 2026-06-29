import 'dart:async';

import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../widgets/overlay_quest_list.dart';
import '../main.dart';
import '../services/quest_service.dart';


class QuestOverlay extends StatefulWidget { // Caso de stateful ya que hay dadas guardadas en esta "imagen" por la que esta imagen cambia segun x situacion

  final QuestService questService;

  const QuestOverlay({
    super.key,
    required this.questService,
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
      if (overlayController.visible) {
        print("He escuchado que se ha encendido");
        _startHideTimer(); // al escuchar que se ha activado, inicia timer tambien
      } else if (!overlayController.visible) {
        print("He escuchado que se ha ido");
      }
      setState(() {}); // Reset de estado
    };

    overlayController.addListener(_overlayListener);
  }

  void _startHideTimer() {
    print("empezando a contar");
    _hideTimer?.cancel(); // Cancela lo pendiente del timer
    _hideTimer = Timer( // Aqui es donde define cuanto dura y que hace
      const Duration(seconds: 3),
          () async {
        overlayController.hide();
      },
    );
  }

  void _cancelHideTimer() {
    print("cancelando el contador");
    _hideTimer?.cancel();
  }

  void _toggleQuest(Quest quest) {
    setState(() {
      questService.updateQuest(quest, changeCompletion: true);
    });
  }

  @override
  void dispose() { // Funcion para detruir la widget al apagar
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold es la estructura básica de una pantalla Material Design.
      backgroundColor: Colors.transparent,
      body: Listener(
        child: MouseRegion(
          onEnter: (_) => _cancelHideTimer(),
          onExit: (_) => _startHideTimer(),
          child: SafeArea( // Es un widget que evita que tu contenido quede debajo de zonas peligrosas del sistema operativo.
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: overlayController.visible ? Colors.grey.withValues(alpha: 0.55) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: overlayController.visible ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "QUEST BOARD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20), // Una caja vacia para poner espacio
                    OverlayQuestList(
                      quests: widget.questService.quests,
                      onQuestTap: _toggleQuest,
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
  }
}