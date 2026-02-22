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

  // Invisible brick mechanic
  bool _isInvisible = false;
  double _opacity = 1.0;
  double _flashTimer = 0.0;
  bool _isFlashing = false;
  static const double _flashInterval = 2.0;
  static const double _flashDuration = 0.15;

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
    position.y += speed * game.gravityDirection.y * game.timeDilation * dt;

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

    // Invisible brick mechanic: fade out past midpoint
    if (!_isInvisible && position.y > game.size.y / 2) {
      _isInvisible = true;
      _opacity = 0.0;
      _flashTimer = 0;
    }

    // Flash hint every 2 seconds while invisible
    if (_isInvisible) {
      _flashTimer += dt;
      if (_isFlashing) {
        _opacity = 0.8;
        if (_flashTimer >= _flashDuration) {
          _isFlashing = false;
          _flashTimer = 0;
          _opacity = 0.0;
        }
      } else {
        _opacity = 0.0;
        if (_flashTimer >= _flashInterval) {
          _isFlashing = true;
          _flashTimer = 0;
        }
      }
    }

    // Remove when it passes off-screen (either direction) to optimize memory
    final isOffBottom = game.gravityDirection.y > 0 && position.y > game.size.y;
    final isOffTop = game.gravityDirection.y < 0 && position.y + size.y < 0;
    if (isOffBottom || isOffTop) {
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
    
    // Apply opacity for invisible brick mechanic
    if (_opacity < 1.0) {
      canvas.saveLayer(
        size.toRect(),
        Paint()..color = Colors.white.withValues(alpha: _opacity),
      );
    }

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

    // Close the saveLayer if opacity was applied
    if (_opacity < 1.0) {
      canvas.restore();
    }
  }
}
