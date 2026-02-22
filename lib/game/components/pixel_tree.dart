import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_dodger_game.dart';

/// Pixel-art tree placed on the grass layer as background decoration.
class PixelTree extends PositionComponent with HasGameReference<BrickDodgerGame> {
  final double treeScale;
  final int seed;

  PixelTree({required Vector2 position, this.treeScale = 1.0, this.seed = 0})
    : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(40 * treeScale, 80 * treeScale);
    priority = 2; // Behind player (player is default 0 but we set ground to 5)
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final p = 4.0 * treeScale; // pixel unit
    final cx = size.x / 2;
    final rng = Random(seed);

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    final trunkDark = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(cx - p * 1.5, size.y * 0.5, p * 3, size.y * 0.5), trunkPaint);
    // Trunk shading
    canvas.drawRect(Rect.fromLTWH(cx + p * 0.5, size.y * 0.5, p, size.y * 0.5), trunkDark);

    // Foliage layers (bottom to top, wider to narrower)
    final leafColors = [
      const Color(0xFF2E7D32), // dark green
      const Color(0xFF388E3C), // medium green
      const Color(0xFF43A047), // lighter green
      const Color(0xFF66BB6A), // highlight
    ];

    // Layer 1 (widest)
    _drawFoliageRow(canvas, cx, size.y * 0.45, p * 5, p * 3, leafColors[0], leafColors[1]);
    // Layer 2
    _drawFoliageRow(canvas, cx, size.y * 0.30, p * 4, p * 3, leafColors[1], leafColors[2]);
    // Layer 3 (top)
    _drawFoliageRow(canvas, cx, size.y * 0.15, p * 3, p * 3, leafColors[2], leafColors[3]);

    // Random leaf pixels sticking out
    for (int i = 0; i < 6; i++) {
      final lx = cx + (rng.nextDouble() - 0.5) * size.x * 0.8;
      final ly = size.y * 0.15 + rng.nextDouble() * size.y * 0.35;
      canvas.drawRect(
        Rect.fromLTWH(lx, ly, p, p),
        Paint()..color = leafColors[rng.nextInt(leafColors.length)],
      );
    }
  }

  void _drawFoliageRow(Canvas canvas, double cx, double y, double halfW, double h, Color main, Color highlight) {
    canvas.drawRect(
      Rect.fromLTWH(cx - halfW, y, halfW * 2, h),
      Paint()..color = main,
    );
    // Highlight on right side
    canvas.drawRect(
      Rect.fromLTWH(cx, y, halfW * 0.6, h * 0.6),
      Paint()..color = highlight,
    );
  }
}
