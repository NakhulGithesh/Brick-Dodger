import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  double lifespan;
  double _timer = 0;
  final double floatSpeed;

  FloatingText({
    required String text,
    required Vector2 position,
    this.lifespan = 1.0,
    this.floatSpeed = 50.0,
  }) : super(
          text: text,
          position: position,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.yellowAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    
    // Float upwards
    position.y -= floatSpeed * dt;

    if (_timer >= lifespan) {
      removeFromParent();
    }
  }
}
