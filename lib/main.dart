import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assegurar que este ya inicializado Flutter, como tocamos ventana habran cambios inesperados si no aseguramos que esta inicializado

  await windowManager.ensureInitialized(); // Lo mismo que lo de arriba pero con el window manager

  WindowOptions windowOptions = const WindowOptions(  //
    size: Size(350, 600),
    center: true,
    title: "QuestBoard",
    alwaysOnTop: true,
    backgroundColor: Colors.transparent,
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
        () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "QUEST LOG",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "□ Acabar Benchmark",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "□ Crear Overlay",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "■ Configurar Flutter",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}