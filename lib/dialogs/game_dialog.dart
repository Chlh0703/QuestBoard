import 'package:flutter/material.dart';

import '../services/game_service.dart';

Future<void> showGameDialog(
  BuildContext context, {
  required GameService gameService,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => GameDialog(gameService: gameService),
  );
}

class GameDialog extends StatelessWidget {
  final GameService gameService;

  const GameDialog({super.key, required this.gameService});

  static const _binaryColors = [Colors.white, Colors.amber];
  static const _colorCycle = [Colors.white, Colors.red, Colors.green, Colors.blue,];

  Future<void> _continue(BuildContext context) async {
    if(!await gameService.advanceToNextLevel()){
      Navigator.of(context).pop();
      return;
    }
  }

  Future<void> _confirmForfeit(BuildContext context) async {
    final targetLevel = gameService.levelNumber > 3
        ? gameService.levelNumber - 3
        : 1;
    final levelsBack = gameService.levelNumber - targetLevel;
    final consequence = levelsBack == 0
        ? 'You are already at level 1, so this will restart it.'
        : 'You will go back $levelsBack levels to level $targetLevel.';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Forfeit level?'),
        content: Text(
          '$consequence Your board and brush will reset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Forfeit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await gameService.forfeitLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gameService,
      builder: (context, child) {
        final colors = gameService.stateCount == 2 ? _binaryColors : _colorCycle;

        return Dialog(
          child: SizedBox(
            width: 900,
            height: 650,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lights On',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'Series ${gameService.seriesNumber} · '
                              'Level ${gameService.levelInSeries} / 15',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Exit game',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        _BoardPanel(
                          title: 'Target',
                          cells: gameService.target,
                          colors: colors,
                        ),
                        const SizedBox(width: 28),
                        _BoardPanel(
                          title: 'Your board',
                          cells: gameService.board,
                          colors: colors,
                          onTap: gameService.tapCell,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (gameService.isSolved)
                        Expanded(
                          child: Text(
                            'Level complete!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      TextButton.icon(
                        onPressed: gameService.restartLevel,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _confirmForfeit(context),
                        icon: const Icon(Icons.fast_rewind),
                        label: const Text('Forfeit'),
                      ),
                      const SizedBox(width: 8),
                      if (gameService.isSolved)
                        FilledButton.icon(
                          onPressed: () => _continue(context),
                          icon: Icon(
                            gameService.levelNumber == 30
                                ? Icons.check
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            gameService.levelNumber == 30 ? 'Finish' : 'Next level',
                          ),
                        ),
                    ],
                  ),
                  if (gameService.stateCount > 2) ...[
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 16,
                      children: [
                        _ColorLegend(color: Colors.red, label: 'Red'),
                        _ColorLegend(color: Colors.blue, label: 'Blue'),
                        _ColorLegend(color: Colors.green, label: 'Green'),
                        _ColorLegend(color: Colors.white, label: 'Empty'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPanel extends StatelessWidget {
  final String title;
  final List<int> cells;
  final List<Color> colors;
  final Future<void> Function(int row, int column)? onTap;

  const _BoardPanel({
    required this.title,
    required this.cells,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: GameService.boardCellCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameService.boardWidth,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ GameService.boardWidth;
                    final column = index % GameService.boardWidth;

                    return Material(
                      color: colors[cells[index]],
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: onTap == null
                            ? null
                            : () async => onTap!(row, column),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
