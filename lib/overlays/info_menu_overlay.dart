import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/brick_dodger_game.dart';
import '../game/managers/storage_helper.dart';
import 'pixel_button.dart';

/// Info menu overlay showing best scores for each game mode.
class InfoMenuOverlay extends StatelessWidget {
  final BrickDodgerGame game;

  const InfoMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final highScores = game.storage.getAllHighScores();

    return SizedBox.expand(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title
              Text(
                'BEST SCORES',
                style: GoogleFonts.pressStart2p(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Scores list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ListView(
                    children: highScores.entries.map((entry) {
                      final displayName =
                          StorageHelper.modeDisplayNames[entry.key] ??
                              entry.key;
                      return _buildScoreRow(displayName, entry.value);
                    }).toList(),
                  ),
                ),
              ),
              // BACK button
              PixelButton(
                label: 'BACK',
                color: const Color(0xFFE64A19),
                onPressed: () => game.navigateTo('mainMenu'),
                width: 180,
                height: 44,
                fontSize: 12,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String modeName, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.grey.shade700, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                modeName,
                style: GoogleFonts.pressStart2p(
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            Text(
              '$score',
              style: GoogleFonts.pressStart2p(
                textStyle: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
