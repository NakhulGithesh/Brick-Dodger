import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/brick_dodger_game.dart';
import 'pixel_button.dart';

/// Store menu overlay showing coin count and a skins placeholder grid.
class StoreMenuOverlay extends StatelessWidget {
  final BrickDodgerGame game;

  const StoreMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final coins = game.storage.getTotalCoins();

    return SizedBox.expand(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Top bar with coin count
              _buildTopBar(coins),
              const SizedBox(height: 30),
              // SKINS title
              Text(
                'SKINS',
                style: GoogleFonts.pressStart2p(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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
              const SizedBox(height: 20),
              // Skins grid placeholder
              Expanded(child: _buildSkinsGrid()),
              const SizedBox(height: 16),
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

  Widget _buildTopBar(int coins) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pixel coin icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107), // Gold
              border: Border.all(color: const Color(0xFFFF8F00), width: 3),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: Text(
              '\$',
              style: GoogleFonts.pressStart2p(
                textStyle: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'COINS: $coins',
            style: GoogleFonts.pressStart2p(
              textStyle: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.6),
              border: Border.all(color: Colors.grey.shade600, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              '?',
              style: GoogleFonts.pressStart2p(
                textStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
