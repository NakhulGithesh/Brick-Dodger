import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../brick_dodger_game.dart';

class Cloud extends PositionComponent with HasGameRef<BrickDodgerGame> {
  final double speed;
  final Random random = Random();

  Cloud({required Vector2 position, required this.speed})
    : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(
      100 + random.nextDouble() * 100,
      50 + random.nextDouble() * 50,
    );
    // Draw clouds behind other game elements
    priority = -1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Clouds drift downwards
    position.y += speed * dt;

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.5); // Dark green

    // Base shape for the cloud
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.6), size.y * 0.4, paint);
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.4), size.y * 0.5, paint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.6), size.y * 0.4, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.15, size.y * 0.5, size.x * 0.7, size.y * 0.5),
        const Radius.circular(20),
      ),
      paint,
    );
  }
}
