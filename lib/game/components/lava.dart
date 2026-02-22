import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../brick_dodger_game.dart';

/// Rising lava that kills the player on contact.
class Lava extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickDodgerGame> {
  double riseSpeed;
  late Paint _lavaPaint;
  late Paint _surfacePaint;
  double _animTimer = 0;

  Lava({this.riseSpeed = 15.0});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.size.x, 40);
    position = Vector2(0, game.size.y - 20); // Start just below ground
    priority = 10;

    _lavaPaint = Paint()
      ..color = const Color(0xCCFF3300); // Semi-transparent red-orange
    _surfacePaint = Paint()..color = const Color(0xFFFF6600);

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Rise upward
    position.y -= riseSpeed * dt;
    _animTimer += dt;

    // Grow the lava rectangle to fill the screen below it
    final cameraY = game.camera.viewfinder.position.y;
    final screenBottom = cameraY + game.size.y;
    size = Vector2(
      game.size.x,
      (screenBottom - position.y).clamp(40.0, 5000.0),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Main lava body
    canvas.drawRect(size.toRect(), _lavaPaint);

    // Animated surface "bubbles"
    final bubblePaint = Paint()..color = const Color(0xFFFFAA00);
    final p = 6.0;
    for (double x = 0; x < size.x; x += 20) {
      final waveY = (x * 0.1 + _animTimer * 3).remainder(6.28);
      final yOff = (waveY > 3.14 ? -1 : 1) * 2.0;
      canvas.drawRect(Rect.fromLTWH(x, yOff, p * 2, p), _surfacePaint);
      if ((x / 20).toInt() % 3 == 0) {
        canvas.drawCircle(Offset(x + p, 4.0 + yOff), p * 0.6, bubblePaint);
      }
    }
  }

  void reset() {
    position = Vector2(0, game.size.y - 20);
    size = Vector2(game.size.x, 40);
  }
}
