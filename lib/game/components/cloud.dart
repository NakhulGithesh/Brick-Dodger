import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_dodger_game.dart';

/// White fluffy pixel-art clouds that drift horizontally at varying speeds.
class Cloud extends PositionComponent with HasGameReference<BrickDodgerGame> {
  final double speed;
  final Random _rng = Random();
  late double _direction; // 1 or -1

  Cloud({required Vector2 position, required this.speed})
    : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(
      80 + _rng.nextDouble() * 60,
      30 + _rng.nextDouble() * 20,
    );
    priority = -1; // Behind bricks and player
    _direction = _rng.nextBool() ? 1.0 : -1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Clouds drift horizontally
    position.x += speed * _direction * dt;

    // Wrap around screen edges
    if (position.x > game.size.x + size.x) {
      position.x = -size.x;
    } else if (position.x < -size.x) {
      position.x = game.size.x + size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final p = 4.0; // pixel size
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final shadowPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);

    // Blocky pixel cloud shape
    // Bottom row (widest)
    canvas.drawRect(Rect.fromLTWH(p * 1, p * 5, size.x - p * 2, p * 2), shadowPaint);
    // Middle row
    canvas.drawRect(Rect.fromLTWH(p * 0, p * 3, size.x, p * 2), paint);
    // Top-left bump
    canvas.drawRect(Rect.fromLTWH(p * 2, p * 1, size.x * 0.3, p * 2), paint);
    // Top-right bump
    canvas.drawRect(Rect.fromLTWH(size.x * 0.5, p * 0, size.x * 0.35, p * 3), paint);
  }
}
