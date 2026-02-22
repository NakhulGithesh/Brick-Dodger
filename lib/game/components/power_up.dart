import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../brick_dodger_game.dart';
import 'player.dart';

enum PowerUpType { shield, slowMo, shrink }

class PowerUp extends PositionComponent with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  final PowerUpType type;
  final double baseSpeed;
  late Paint _paint;

  PowerUp({
    required Vector2 position,
    required this.baseSpeed,
    required this.type,
  }) : super(
          position: position,
          size: Vector2(30, 30),
        ) {
    _paint = Paint()
      ..color = _getColorForType(type)
      ..style = PaintingStyle.fill;
  }

  Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blueAccent;
      case PowerUpType.slowMo:
        return Colors.purpleAccent;
      case PowerUpType.shrink:
        return Colors.orangeAccent;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Power-ups should fall at the normal game speed even if slow-mo is active
    position.y += baseSpeed * dt;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();
    canvas.drawCircle(rect.center, size.x / 2, _paint);
    
    // Draw an icon or initial
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getTextForType(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
    );
  }

  String _getTextForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return 'S';
      case PowerUpType.slowMo:
        return 'M';
      case PowerUpType.shrink:
        return '-';
    }
  }
}
