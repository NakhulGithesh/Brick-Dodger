import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_dodger_game.dart';

/// Blue HUD bar showing remaining Bullet Time stamina.
/// Only visible during the 'bullet_time' game mode.
class StaminaBar extends PositionComponent
    with HasGameReference<BrickDodgerGame> {
  late Paint _bgPaint;
  late Paint _fillPaint;
  late Paint _borderPaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(160, 14);
    position = Vector2(game.size.x / 2 - size.x / 2, 20);
    priority = 100; // HUD layer

    _bgPaint = Paint()..color = const Color(0xFF333333);
    _fillPaint = Paint()..color = const Color(0xFF42A5F5);
    _borderPaint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }

  @override
  void render(Canvas canvas) {
    if (game.currentMode != 'bullet_time') return;

    super.render(canvas);
    final rect = size.toRect();

    // Background
    canvas.drawRect(rect, _bgPaint);

    // Filled portion based on stamina
    final fillWidth = size.x * game.stamina.clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, 0, fillWidth, size.y), _fillPaint);

    // Glow effect when bullet time is active
    if (game.bulletTimeActive) {
      final glowPaint = Paint()
        ..color = const Color(0xFF64B5F6).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
      canvas.drawRect(rect, glowPaint);
    }

    // Border
    canvas.drawRect(rect, _borderPaint);

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'STAMINA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }
}
