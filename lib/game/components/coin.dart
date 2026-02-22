import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_dodger_game.dart';

/// A gold coin that spawns during "Coin Rush" events.
/// Collecting it increments wallet coins — does NOT trigger game over.
class Coin extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  final double speed;
  double _spinAngle = 0;
  final Random _rng = Random();

  late Paint _fillPaint;
  late Paint _borderPaint;
  late Paint _shinePaint;

  Coin({required Vector2 position, required this.speed})
      : super(position: position, size: Vector2(28, 28)) {
    _fillPaint = Paint()..color = const Color(0xFFFFC107); // Gold
    _borderPaint = Paint()
      ..color = const Color(0xFFFF8F00) // Dark amber border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    _shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fall using gravity direction (consistent with bricks)
    position.y += speed * game.gravityDirection.y * game.slowMoMultiplier * dt;

    // Spin animation
    _spinAngle += dt * 4.0;

    // Remove when off-screen (either direction)
    if (game.gravityDirection.y > 0 && position.y > game.size.y + size.y) {
      removeFromParent();
    } else if (game.gravityDirection.y < 0 && position.y + size.y < -size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final cx = size.x / 2;
    final cy = size.y / 2;
    final radius = size.x / 2;

    // Simulate 3D spin by squishing the horizontal scale
    final scaleX = cos(_spinAngle).abs().clamp(0.3, 1.0);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scaleX, 1.0);

    // Coin body
    canvas.drawCircle(Offset.zero, radius, _fillPaint);
    canvas.drawCircle(Offset.zero, radius, _borderPaint);

    // Inner ring
    canvas.drawCircle(
      Offset.zero,
      radius * 0.7,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dollar sign
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Color(0xFF5D4037),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    // Shine highlight
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.2,
      _shinePaint,
    );

    canvas.restore();
  }
}
