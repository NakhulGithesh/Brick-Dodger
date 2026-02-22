import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_dodger_game.dart';
import 'brick.dart';
import 'power_up.dart';

class Player extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  late Paint _skinPaint;
  late Paint _shirtPaint;
  late Paint _pantsPaint;

  double _animationTime = 0.0;
  double _lastX = 0.0;
  bool isMoving = false;
  
  bool hasShield = false;

  /// Near-miss detection radius (world units from player center)
  static const double nearMissRadius = 80.0;

  Player() : super(size: Vector2(30, 60)) {
    _skinPaint = Paint()..color = const Color(0xFFFFC0CB);
    _shirtPaint = Paint()..color = Colors.blue;
    _pantsPaint = Paint()..color = Colors.blue[800]!;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2(game.size.x / 2 - size.x / 2, game.size.y - size.y - 50);
    add(RectangleHitbox(position: Vector2(5, 5), size: Vector2(20, 50)));
    _lastX = position.x;
  }

  void move(Vector2 delta) {
    position.add(Vector2(delta.x, 0));
    if (position.x < 0) {
      position.x = 0;
    } else if (position.x + size.x > game.size.x) {
      position.x = game.size.x - size.x;
    }
  }

  void activateShrink() {
    scale = Vector2.all(0.5);
    Future.delayed(const Duration(seconds: 8), () {
      if (isMounted) scale = Vector2.all(1.0);
    });
  }

  /// Returns the center point of the player in world space.
  Vector2 get center => position + size / 2;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Brick) {
      if (hasShield) {
        hasShield = false;
        other.removeFromParent();
      } else {
        game.gameOver();
      }
    } else if (other is PowerUp) {
      game.collectPowerUp(other.type);
      other.removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    double targetAngle = 0.0;
    
    if ((position.x - _lastX).abs() > 0.1) {
      isMoving = true;
      _animationTime += dt * 15;
      targetAngle = (position.x > _lastX) ? 0.1 : -0.1;
    } else {
      isMoving = false;
      _animationTime = 0.0;
    }
    
    angle += (targetAngle - angle) * dt * 10;
    _lastX = position.x;

    // Near-miss detection: check all bricks within proximity
    final playerCenter = center;
    for (final brick in game.children.whereType<Brick>()) {
      if (brick.triggeredNearMiss) continue;
      final brickCenter = brick.position + brick.size / 2;
      final dist = playerCenter.distanceTo(brickCenter);
      if (dist < nearMissRadius) {
        brick.triggeredNearMiss = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final headRadius = 10.0;
    final bodyWidth = 16.0;
    final bodyHeight = 22.0;
    final legWidth = 6.0;
    final legHeight = 15.0;

    final centerX = size.x / 2;

    double leftLegOffset = 0;
    double rightLegOffset = 0;
    if (isMoving) {
      leftLegOffset = sin(_animationTime) * 8;
      rightLegOffset = sin(_animationTime + pi) * 8;
    }

    // Left Leg
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - bodyWidth / 2,
        headRadius * 2 + bodyHeight,
        legWidth,
        legHeight - leftLegOffset.abs(),
      ),
      _pantsPaint,
    );

    // Right Leg
    canvas.drawRect(
      Rect.fromLTWH(
        centerX + bodyWidth / 2 - legWidth,
        headRadius * 2 + bodyHeight,
        legWidth,
        legHeight - rightLegOffset.abs(),
      ),
      _pantsPaint,
    );

    // Body
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - bodyWidth / 2,
        headRadius * 2,
        bodyWidth,
        bodyHeight,
      ),
      _shirtPaint,
    );

    // Head
    canvas.drawCircle(Offset(centerX, headRadius + 2), headRadius, _skinPaint);

    // Arms
    double leftArmSwing = isMoving ? sin(_animationTime + pi) * 6 : 0;
    double rightArmSwing = isMoving ? sin(_animationTime) * 6 : 0;

    final armPaint = Paint()
      ..color = _skinPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX - bodyWidth / 2, headRadius * 2 + 4),
      Offset(centerX - bodyWidth / 2 - 4, headRadius * 2 + 15 + leftArmSwing),
      armPaint,
    );

    canvas.drawLine(
      Offset(centerX + bodyWidth / 2, headRadius * 2 + 4),
      Offset(centerX + bodyWidth / 2 + 4, headRadius * 2 + 15 + rightArmSwing),
      armPaint,
    );

    // Shield Aura
    if (hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, size.y / 2), size.y * 0.7, shieldPaint);
      
      final shieldOutline = Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(centerX, size.y / 2), size.y * 0.7, shieldOutline);
    }
  }
}
