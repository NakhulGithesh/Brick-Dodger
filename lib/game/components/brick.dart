import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'dart:math';

import '../brick_dodger_game.dart';

class Brick extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  final double speed;
  late Paint _basePaint;
  late Paint _mortarPaint;
  late Paint _shadowPaint;
  bool triggeredNearMiss = false;

  double _trailTimer = 0.0;
  final Random _random = Random();

  Brick({required Vector2 position, required this.speed})
    : super(position: position, size: Vector2(60, 25)) {
    _basePaint = Paint()..color = const Color(0xFFB22222); // Firebrick red
    _mortarPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    _shadowPaint = Paint()
      ..color = const Color(0xFF8B0000); // Darker red for shadow
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox(position: Vector2(2, 2), size: Vector2(56, 21)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * (game as dynamic).slowMoMultiplier * dt;

    // Particle Trails
    _trailTimer += dt;
    if (_trailTimer > 0.05) {
      _trailTimer = 0.0;
      game.add(
        ParticleSystemComponent(
          position: position + Vector2(size.x / 2 + (_random.nextDouble() * 20 - 10), 0),
          particle: Particle.generate(
            count: 2,
            lifespan: 0.3 + _random.nextDouble() * 0.2,
            generator: (i) => AcceleratedParticle(
              speed: Vector2(0, -speed * 0.2), // move slightly up relative to screen
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = (1 - particle.progress) * 0.4;
                  canvas.drawCircle(
                    Offset.zero,
                    2.0 + _random.nextDouble() * 2.0,
                    Paint()..color = Colors.white.withOpacity(opacity),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    // Remove when it passes the bottom of the screen to optimize memory
    if (position.y > game.size.y) {
      removeFromParent();
      
      // Screen Shake
      try {
        (game.camera as dynamic).viewfinder.add(
          MoveEffect.by(Vector2(5, 5), EffectController(duration: 0.05, alternate: true))
        );
      } catch (_) {
        try {
          (game.camera as dynamic).shake(intensity: 5.0);
        } catch (_) {}
      }

      game.brickDodged(this);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();

    // Draw brick base
    canvas.drawRect(rect, _basePaint);

    // Draw 3D shadow polygon
    final shadowPath = Path()
      ..moveTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x, 0)
      ..lineTo(size.x - 3, 3)
      ..lineTo(size.x - 3, size.y - 3)
      ..lineTo(3, size.y - 3)
      ..close();
    canvas.drawPath(shadowPath, _shadowPaint);

    // Draw mortar outline
    canvas.drawRect(rect, _mortarPaint);

    // Draw brick pattern (mortar lines inside)
    canvas.drawLine(
      Offset(size.x * 0.3, 0),
      Offset(size.x * 0.3, size.y / 2),
      _mortarPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.7, size.y / 2),
      Offset(size.x * 0.7, size.y),
      _mortarPaint,
    );
    canvas.drawLine(
      Offset(0, size.y / 2),
      Offset(size.x, size.y / 2),
      _mortarPaint,
    );
  }
}
