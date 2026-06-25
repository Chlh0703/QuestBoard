import 'dart:async';

import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../widgets/quest_list.dart';
import '../main.dart';
import '../services/overlay_service.dart';


class QuestOverlay extends StatefulWidget { // Caso de stateful ya que hay dadas guardadas en esta "imagen" por la que esta imagen cambia segun x situacion

  final List<Quest> quests;

  const QuestOverlay({
    super.key,
    required this.quests,
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

    _overlayListener = () async {
      if (overlayController.visible) {
        print("He escuchado que se ha encendido");
        _startHideTimer(); // al escuchar que se ha activado, inicia timer tambien
        await OverlayService.disableClickThrough();
      } else if (!overlayController.visible) {
        print("He escuchado que se ha ido");
        await OverlayService.enableClickThrough();
      }
      setState(() {}); // Reset de estado
    };

    overlayController.addListener(_overlayListener);
  }

  void _startHideTimer() {
    _hideTimer?.cancel(); // Cancela lo pendiente del timer, basicamente un reset
    _hideTimer = Timer( // Aqui es donde define cuanto dura y que hace
      const Duration(seconds: 3),
          () async {
        overlayController.hide();
      },
    );
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
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
      body: MouseRegion( // Un widget que detecta las actividades del ratón dentro de la zona de interfaz (region)
        onEnter: (_) => _cancelHideTimer(), // Dada X situacion que hacer
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
                  QuestList(
                    quests: widget.quests,
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}