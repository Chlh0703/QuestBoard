import 'package:flutter/material.dart';

Future<bool?> showGameMainMenuDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const GameMainMenuDialog(),
  );
}

class GameMainMenuDialog extends StatelessWidget {
  const GameMainMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.extension_outlined),
          SizedBox(width: 12),
          Text('Lights Out'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.grid_on,
              size: 56,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            Text(
              'Level Mode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Play through all three series in order. '
              'The next series starts automatically when you finish the current one.'
              'Difficulty will change drastically between series',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text('3 series · 15 levels each'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Exit'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start'),
        ),
      ],
    );
  }
}
