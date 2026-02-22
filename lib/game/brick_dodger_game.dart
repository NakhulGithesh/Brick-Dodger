import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'components/player.dart';
import 'components/brick.dart';
import 'components/cloud.dart';
import 'components/power_up.dart';
import 'components/floating_text.dart';
import 'components/ground.dart';

class BrickDodgerGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;
  int score = 0;
  int bestScore = 0;
  late TextComponent _scoreText;
  late TextComponent _bestScoreText;

  double _spawnTimer = 0;
  double _spawnInterval = 2.0;
  double _brickSpeed = 200.0;

  double _cloudSpawnTimer = 0;
  double _cloudSpawnInterval = 3.0;

  double _difficultyTimer = 0;
  double slowMoMultiplier = 1.0;

  int comboCounter = 0;
  int scoreMultiplier = 1;
  double _stationaryTimer = 0;

  @override
  Color backgroundColor() => const Color(0xFF4CAF50); // Green grass

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;

    add(Ground());

    player = Player();
    add(player);

    _scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      position: Vector2(20, 50),
    );
    add(_scoreText);

    _bestScoreText = TextComponent(
      text: 'Best: $bestScore',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          textStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
      position: Vector2(20, 90),
    );
    add(_bestScoreText);
  }

  @override
  void update(double dt) {
    if (paused) return;
    super.update(dt);

    if (player.isMoving) {
      _stationaryTimer = 0;
    } else {
      _stationaryTimer += dt;
      if (_stationaryTimer > 3.0) {
        scoreMultiplier = 1;
        comboCounter = 0;
        _scoreText.text = 'Score: $score'; // Reset visual multiplier
      }
    }

    _difficultyTimer += dt;
    // Increase difficulty every 10 seconds
    if (_difficultyTimer >= 10.0) {
      _difficultyTimer = 0;
      _spawnInterval = max(0.5, _spawnInterval - 0.2);
      _brickSpeed += 50.0;
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnBrick();
    }

    _cloudSpawnTimer += dt;
    if (_cloudSpawnTimer >= _cloudSpawnInterval) {
      _cloudSpawnTimer = 0;
      _spawnCloud();
    }
  }

  void _spawnBrick() {
    final random = Random();
    final brickWidth = 60.0;
    final brickHeight = 25.0;

    // Random X between 0 and (screenWidth - brickWidth)
    final randomX = random.nextDouble() * (size.x - brickWidth);

    final brick = Brick(
      position: Vector2(randomX, -brickHeight), // Spawn above screen
      speed: _brickSpeed,
    );
    add(brick);

    // 5% chance to spawn a power-up alongside a brick
    if (random.nextDouble() < 0.05) {
      _spawnPowerUp();
    }
  }

  void _spawnPowerUp() {
    final random = Random();
    final powerUpTypes = PowerUpType.values;
    final type = powerUpTypes[random.nextInt(powerUpTypes.length)];
    
    // Random X between 0 and (screenWidth - 30)
    final randomX = random.nextDouble() * (size.x - 30);
    
    final powerUp = PowerUp(
      position: Vector2(randomX, -30),
      baseSpeed: 150.0,
      type: type,
    );
    add(powerUp);
  }

  void _spawnCloud() {
    final random = Random();
    final cloudWidth = 200.0;
    final cloudHeight = 100.0;

    // Random X between 0 and size.x
    double randomX = random.nextDouble() * size.x;
    if (size.x > cloudWidth) {
      randomX = random.nextDouble() * (size.x - cloudWidth);
    }

    final cloud = Cloud(
      position: Vector2(randomX, -cloudHeight),
      speed: 20.0 + random.nextDouble() * 30.0, // Clouds move slower
    );
    add(cloud);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!paused) {
      player.move(info.delta.global);
    }
  }

  void brickDodged(Brick brick) {
    comboCounter++;
    if (comboCounter >= 10) {
      scoreMultiplier++;
      comboCounter = 0;
      add(FloatingText(
        text: 'Combo $scoreMultiplier' 'x!',
        position: Vector2(size.x / 2 - 40, size.y / 2),
        floatSpeed: 80.0,
      ));
    }

    int points = 1 * scoreMultiplier;
    if (brick.triggeredNearMiss) {
      points += 5 * scoreMultiplier;
      add(FloatingText(
        text: 'Close! +${5 * scoreMultiplier}',
        position: Vector2(brick.position.x, brick.position.y - 20),
      ));
    }

    score += points;
    _scoreText.text = 'Score: $score (${scoreMultiplier}x)';
    if (score > bestScore) {
      bestScore = score;
      _bestScoreText.text = 'Best: $bestScore';
    }
  }

  void collectPowerUp(PowerUpType type) {
    if (type == PowerUpType.shield) {
      player.hasShield = true;
    } else if (type == PowerUpType.slowMo) {
      slowMoMultiplier = 0.5;
      Future.delayed(const Duration(seconds: 5), () {
        slowMoMultiplier = 1.0;
      });
    } else if (type == PowerUpType.shrink) {
      player.activateShrink();
    }
  }

  void gameOver() {
    pauseEngine();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('bestScore', bestScore);
    });
    overlays.add('GameOver');
  }

  void resetGame() {
    // Remove all bricks, clouds, and power-ups
    children.whereType<Brick>().forEach((brick) => brick.removeFromParent());
    children.whereType<Cloud>().forEach((cloud) => cloud.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());

    score = 0;
    _scoreText.text = 'Score: 0';
    _spawnTimer = 0;
    _spawnInterval = 2.0;
    _brickSpeed = 200.0;
    _cloudSpawnTimer = 0;
    _difficultyTimer = 0;
    slowMoMultiplier = 1.0;
    player.hasShield = false;
    
    comboCounter = 0;
    scoreMultiplier = 1;
    _stationaryTimer = 0;

    // Reset player position
    player.scale = Vector2.all(1.0);
    player.position = Vector2(
      size.x / 2 - player.size.x / 2,
      size.y - player.size.y - 50,
    );

    overlays.remove('GameOver');
    resumeEngine();
  }
}
