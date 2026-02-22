import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/brick_dodger_game.dart';
import 'pixel_button.dart';

/// Modal that pops up to explain the currently selected game mode
class ModeBriefingOverlay extends StatefulWidget {
  final BrickDodgerGame game;

  const ModeBriefingOverlay({super.key, required this.game});

  @override
  State<ModeBriefingOverlay> createState() => _ModeBriefingOverlayState();
}

class _ModeBriefingOverlayState extends State<ModeBriefingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getModeDescription(String modeKey) {
    switch (modeKey) {
      case 'classic':
        return "Avoid the falling bricks! Watch out—after 100 points, bricks fall faster, but look out for rare Coin Rush events!";
      case 'gravity_flip':
        return "The world is turning upside down! Every 10 seconds, gravity reverses. Be ready to dodge bricks falling from the bottom!";
      case 'invisible_bricks':
        return "Don't trust your eyes. Bricks turn invisible halfway down. Memorize their path to survive the shadows!";
      case 'lava':
        return "Escape the heat! Jump automatically between green platforms to climb higher. Don't fall into the rising lava!";
      case 'bullet_time':
        return "Control time itself. Hold two fingers on the screen to slow down the world while you move at normal speed!";
      case 'size_matters':
        return "The better you do, the bigger you get. Dodge bricks to grow, but catch yellow pills to shrink back down!";
      default:
        return "Survive as long as you can!";
    }
  }

  String _getModeTitle(String modeKey) {
    switch (modeKey) {
      case 'classic':
        return "CLASSIC";
      case 'gravity_flip':
        return "GRAVITY FLIP";
      case 'invisible_bricks':
        return "INVISIBLE BRICKS";
      case 'lava':
        return "THE FLOOR IS LAVA";
      case 'bullet_time':
        return "BULLET TIME";
      case 'size_matters':
        return "SIZE MATTERS";
      default:
        return "UNKNOWN MODE";
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeKey = widget.game.pendingMode;
    final title = _getModeTitle(modeKey);
    final description = _getModeDescription(modeKey);

    return SizedBox.expand(
      child: Container(
        // Semi-transparent dark background
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50), // Dark blue slate
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFFFC107), // Amber yellow
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      textStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PixelButton(
                    label: 'START!',
                    color: const Color(0xFF4CAF50), // Green for go
                    onPressed: () {
                      _controller.reverse().then((_) {
                        widget.game.startGame(modeKey);
                      });
                    },
                    width: 200,
                    height: 50,
                  ),
                  const SizedBox(height: 12),
                  // Optional close/cancel button to go back to modes
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) {
                        widget.game.navigateTo('mainMenu');
                      });
                    },
                    child: Text(
                      'BACK TO MENU',
                      style: GoogleFonts.pressStart2p(
                        textStyle: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
