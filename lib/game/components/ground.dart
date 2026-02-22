import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_dodger_game.dart';

/// Pixel-art style ground with grass blades and dirt layers.
class Ground extends PositionComponent with HasGameReference<BrickDodgerGame> {
  late double _groundHeight;
  final Random _random = Random(42); // Fixed seed for consistent grass

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _groundHeight = game.size.y * 0.08;
    size = Vector2(game.size.x, _groundHeight);
    position = Vector2(0, game.size.y - _groundHeight);
    priority = 5; // Above background, below player
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final pixelSize = 4.0;

    // Dark dirt base
    canvas.drawRect(
      Rect.fromLTWH(0, pixelSize * 4, size.x, size.y - pixelSize * 4),
      Paint()..color = const Color(0xFF5D3A1A),
    );

    // Medium brown dirt layer
    canvas.drawRect(
      Rect.fromLTWH(0, pixelSize * 3, size.x, pixelSize * 3),
      Paint()..color = const Color(0xFF7B4F2A),
    );

    // Top grass layer (bright green)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, pixelSize * 3),
      Paint()..color = const Color(0xFF4CAF50),
    );

    // Darker grass accent line
    canvas.drawRect(
      Rect.fromLTWH(0, pixelSize * 2, size.x, pixelSize),
      Paint()..color = const Color(0xFF388E3C),
    );

    // Pixel grass blades sticking up
    final grassBladePaint = Paint()..color = const Color(0xFF66BB6A);
    final darkGrassBlade = Paint()..color = const Color(0xFF43A047);
    final rng = Random(42);

    for (double x = 0; x < size.x; x += pixelSize * 2) {
      final h = (rng.nextInt(3) + 1) * pixelSize;
      final useDark = rng.nextBool();
      canvas.drawRect(
        Rect.fromLTWH(x, -h, pixelSize, h),
        useDark ? darkGrassBlade : grassBladePaint,
      );
    }

    // Dirt pixel dots for texture
    final dirtDotPaint = Paint()..color = const Color(0xFF4E2E10);
    final lightDirtDot = Paint()..color = const Color(0xFF8B6340);
    for (int i = 0; i < 30; i++) {
      final dx = rng.nextDouble() * size.x;
      final dy = pixelSize * 5 + rng.nextDouble() * (size.y - pixelSize * 6);
      canvas.drawRect(
        Rect.fromLTWH(dx, dy, pixelSize, pixelSize),
        rng.nextBool() ? dirtDotPaint : lightDirtDot,
      );
    }
  }
}
