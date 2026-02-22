import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/brick_dodger_game.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: GameWidgetWrapper())));
}

class GameWidgetWrapper extends StatefulWidget {
  const GameWidgetWrapper({super.key});

  @override
  State<GameWidgetWrapper> createState() => _GameWidgetWrapperState();
}

class _GameWidgetWrapperState extends State<GameWidgetWrapper> {
  late final BrickDodgerGame game;

  @override
  void initState() {
    super.initState();
    game = BrickDodgerGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      overlayBuilderMap: {
        'GameOver': (context, BrickDodgerGame game) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Score: ${game.score}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Best Score: ${game.bestScore}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      game.resetGame();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
          );
        },
      },
    );
  }
}
