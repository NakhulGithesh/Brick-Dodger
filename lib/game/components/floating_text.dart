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
               Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
             ],
           ),
         ),
       ) {
    priority = 100;
  }

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

  @override
  void render(Canvas canvas) {
    if (_timer > 0) {
      final opacity = (1.0 - (_timer / lifespan)).clamp(0.0, 1.0);
      canvas.saveLayer(
        null, // bounds can be null here to apply to whole component space
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}
