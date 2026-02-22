import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../brick_dodger_game.dart';

/// A green platform brick that the player can stand on in Lava mode.
class SafeBrick extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  final double speed;
  late Paint _basePaint;
  late Paint _highlightPaint;
  late Paint _outlinePaint;

  SafeBrick({required Vector2 position, required this.speed})
    : super(position: position, size: Vector2(70, 14)) {
    _basePaint = Paint()..color = const Color(0xFF4CAF50);
    _highlightPaint = Paint()..color = const Color(0xFF81C784);
    _outlinePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * game.slowMoMultiplier * dt;

    // Clean up if it falls far below the camera
    final cameraY = game.camera.viewfinder.position.y;
    if (position.y > cameraY + game.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();

    // Base green
    canvas.drawRect(rect, _basePaint);

    // Top highlight strip
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4), _highlightPaint);

    // Outline
    canvas.drawRect(rect, _outlinePaint);

    // Pixel pattern
    final dotPaint = Paint()..color = const Color(0xFF388E3C);
    for (double x = 6; x < size.x - 6; x += 12) {
      canvas.drawRect(Rect.fromLTWH(x, 5, 3, 3), dotPaint);
    }
  }
}
