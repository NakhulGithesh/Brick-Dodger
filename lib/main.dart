import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game/brick_dodger_game.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/store_menu_overlay.dart';
import 'overlays/info_menu_overlay.dart';
import 'overlays/pixel_button.dart';

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
      initialActiveOverlays: const ['mainMenu'],
      overlayBuilderMap: {
        // ---------- Main Menu ----------
        'mainMenu': (context, BrickDodgerGame game) {
          return MainMenuOverlay(game: game);
        },

        // ---------- Store Menu ----------
        'storeMenu': (context, BrickDodgerGame game) {
          return StoreMenuOverlay(game: game);
        },

        // ---------- Info Menu ----------
        'infoMenu': (context, BrickDodgerGame game) {
          return InfoMenuOverlay(game: game);
        },

        // ---------- Game Over ----------
        'GameOver': (context, BrickDodgerGame game) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                border: Border.all(color: Colors.grey.shade700, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME OVER',
                    style: GoogleFonts.pressStart2p(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.redAccent,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SCORE: ${game.score}',
                    style: GoogleFonts.pressStart2p(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'BEST: ${game.bestScore}',
                    style: GoogleFonts.pressStart2p(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PixelButton(
                    label: 'RESTART',
                    color: const Color(0xFF4CAF50),
                    onPressed: () => game.resetGame(),
                    width: 200,
                    height: 46,
                    fontSize: 12,
                  ),
                  const SizedBox(height: 12),
                  PixelButton(
                    label: 'MAIN MENU',
                    color: const Color(0xFF2196F3),
                    onPressed: () => game.returnToMainMenu(),
                    width: 200,
                    height: 46,
                    fontSize: 12,
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
