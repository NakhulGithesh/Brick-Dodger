import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent with HasGameRef {
  late Paint _dirtPaint;
  late Paint _grassPaint;
  
  double _scrollOffset = 0;
  final double _speed = 100.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Bottom 10% of the screen
    size = Vector2(gameRef.size.x, gameRef.size.y * 0.1);
    position = Vector2(0, gameRef.size.y - size.y);
    
    // Draw on top of background but behind player/bricks if possible, 
    // or just let default priority handle it since we add it first in the game.
    priority = 0;

    _dirtPaint = Paint()..color = const Color(0xFF5D4037); // Brown dirt
    _grassPaint = Paint()..color = const Color(0xFF388E3C); // Darker green grass top
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Scroll the texture pattern based on game speed, or just constantly
    double currentSpeed = _speed;
    try {
      currentSpeed = _speed * (gameRef as dynamic).slowMoMultiplier;
    } catch (_) {}
    
    _scrollOffset += currentSpeed * dt;
    
    // Loop the offset every 40 pixels (size of our pattern)
    if (_scrollOffset >= 40.0) {
      _scrollOffset -= 40.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final rect = size.toRect();
    
    // Base dirt
    canvas.drawRect(rect, _dirtPaint);
    
    // Grass top layer
    final grassRect = Rect.fromLTWH(0, 0, size.x, size.y * 0.3);
    canvas.drawRect(grassRect, _grassPaint);

    // Draw scrolling pattern lines to simulate movement
    final patternPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 3.0;

    for (double x = -40.0; x < size.x; x += 40.0) {
      double drawX = x + _scrollOffset;
      // Slanted lines for dirt texture
      canvas.drawLine(
        Offset(drawX, size.y * 0.3), 
        Offset(drawX - 20, size.y), 
        patternPaint
      );
      
      // Grass tufts
      canvas.drawLine(
        Offset(drawX, 0), 
        Offset(drawX + 10, size.y * 0.3), 
        Paint()..color = const Color(0xFF2E7D32)..strokeWidth = 4.0
      );
    }
  }
}
