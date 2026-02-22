import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/brick_dodger_game.dart';
import 'pixel_button.dart';

/// The main menu overlay, showing PLAY / STORE / INFO buttons
/// or the mode selection list when PLAY is tapped.
class MainMenuOverlay extends StatefulWidget {
  final BrickDodgerGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  bool _showModes = false;

  static const List<_ModeInfo> _modes = [
    _ModeInfo('CLASSIC', 'classic'),
    _ModeInfo('GRAVITY FLIP', 'gravity_flip'),
    _ModeInfo('THE FLOOR IS LAVA', 'the_floor_is_lava'),
    _ModeInfo('BULLET TIME', 'bullet_time'),
    _ModeInfo('SIZE MATTERS', 'size_matters'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildTitle(),
              const Spacer(),
              _showModes ? _buildModeSelection() : _buildMainButtons(),
              const Spacer(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Stack(
      children: [
        // Brown outline / shadow layer
        Text(
          'BRICK DODGER',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            textStyle: TextStyle(
              fontSize: 28,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = const Color(0xFF5D4037), // Brown dirt
            ),
          ),
        ),
        // Green grassy fill
        Text(
          'BRICK DODGER',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            textStyle: const TextStyle(
              fontSize: 28,
              color: Color(0xFF4CAF50), // Green
              shadows: [
                Shadow(
                  color: Color(0xFF2E7D32),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelButton(
          label: 'PLAY',
          color: const Color(0xFF4CAF50), // Green
          onPressed: () => setState(() => _showModes = true),
        ),
        const SizedBox(height: 16),
        PixelButton(
          label: 'STORE',
          color: const Color(0xFF2196F3), // Blue
          onPressed: () => widget.game.navigateTo('storeMenu'),
        ),
        const SizedBox(height: 16),
        PixelButton(
          label: 'INFO',
          color: const Color(0xFF4CAF50), // Green
          onPressed: () => widget.game.navigateTo('infoMenu'),
        ),
      ],
    );
  }

  Widget _buildModeSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._modes.map((mode) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PixelButton(
                label: mode.display,
                color: const Color(0xFF78909C), // Blue-grey for mode buttons
                onPressed: () {
                  widget.game.startGame(mode.key);
                },
                fontSize: 10,
                width: 260,
                height: 44,
              ),
            )),
        const SizedBox(height: 6),
        PixelButton(
          label: 'BACK',
          color: const Color(0xFFE64A19), // Deep orange
          onPressed: () => setState(() => _showModes = false),
          width: 180,
          height: 44,
          fontSize: 12,
        ),
      ],
    );
  }
}

class _ModeInfo {
  final String display;
  final String key;
  const _ModeInfo(this.display, this.key);
}
