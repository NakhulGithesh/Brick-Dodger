import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/effects.dart';
import 'dart:math';

import 'components/player.dart';
import 'components/brick.dart';
import 'components/cloud.dart';
import 'components/coin.dart';
import 'components/power_up.dart';
import 'components/floating_text.dart';
import 'components/ground.dart';
import 'components/pixel_tree.dart';
import 'components/lava.dart';
import 'components/safe_brick.dart';
import 'components/stamina_bar.dart';
import 'managers/storage_helper.dart';
import 'managers/game_data.dart';

class BrickDodgerGame extends FlameGame
    with MultiTouchDragDetector, MultiTouchTapDetector, HasCollisionDetection {
  late Player player;
  int score = 0;
  int bestScore = 0;
  late TextComponent _scoreText;
  late TextComponent _bestScoreText;

  double _spawnTimer = 0;
  double _spawnInterval = 2.0;
  double _brickSpeed = 200.0;

  double _cloudSpawnTimer = 0;
  final double _cloudSpawnInterval = 3.0;

  double get _groundHeight => size.y * 0.08;

  double _difficultyTimer = 0;
  double slowMoMultiplier = 1.0;

  int comboCounter = 0;
  int scoreMultiplier = 1;
  double _stationaryTimer = 0;

  bool _gameStarted = false;
  String currentMode = 'classic';

  // --- Bullet Time ---
  double stamina = 1.0;
  bool bulletTimeActive = false;
  double timeDilation = 1.0; // multiplier for speeds when bullet time is active
  final Set<int> _tappedPointers = {};
  final Set<int> _draggedPointers = {};

  // For Size Matters mode---
  int _lastShrinkPillScore = 0;
  bool _giantModeTriggered = false;

  // --- Coin Rush (Classic mode) ---
  bool coinRushActive = false;
  double _coinRushTimer = 0;
  double _coinRushCheckTimer = 0;
  bool _speedBoosted = false;
  int walletCoins = 0;
  late GameData gameData;

  // --- Gravity Flip ---
  Vector2 gravityDirection = Vector2(0, 1);
  double _gravityFlipTimer = 0;

  final StorageHelper storage = StorageHelper();

  Lava? _lava;
  double _highestPlatformY = 0;
  double _distanceClimbed = 0;

  /// All known overlay keys — used by navigateTo to clear stale overlays.
  static const List<String> _allOverlayKeys = [
    'mainMenu',
    'storeMenu',
    'infoMenu',
    'GameOver',
    'modeBriefing',
  ];

  // Stores the selected mode before the briefing starts it.
  String pendingMode = '';

  /// Centralized overlay navigation: removes ALL overlays then shows [target].
  /// Pass `null` to clear overlays without showing a new one (e.g. gameplay).
  void navigateTo(String? target) {
    for (final key in _allOverlayKeys) {
      if (overlays.isActive(key)) {
        overlays.remove(key);
      }
    }
    if (target != null) {
      overlays.add(target);
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await storage.init();
    gameData = storage.loadGameData();
    walletCoins = gameData.totalCoins;
    bestScore = storage.getHighScore(
      currentMode,
    ); // Load best score for current mode

    add(Ground());

    // Add background trees on the grass
    final groundHeight = size.y * 0.08;
    final treeY = size.y - groundHeight - 70; // Trees sit on top of ground
    add(
      PixelTree(
        position: Vector2(size.x * 0.1, treeY),
        treeScale: 1.0,
        seed: 1,
      ),
    );
    add(
      PixelTree(
        position: Vector2(size.x * 0.5, treeY - 10),
        treeScale: 1.2,
        seed: 2,
      ),
    );
    add(
      PixelTree(
        position: Vector2(size.x * 0.85, treeY + 5),
        treeScale: 0.9,
        seed: 3,
      ),
    );

    // Spawn initial clouds at random Y positions (top half of sky)
    final rng = Random();
    for (int i = 0; i < 4; i++) {
      add(
        Cloud(
          position: Vector2(
            rng.nextDouble() * size.x,
            rng.nextDouble() * size.y * 0.3,
          ),
          speed: 10.0 + rng.nextDouble() * 20.0,
        ),
      );
    }

    player = Player();
    add(player);

    add(StaminaBar());

    _scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
              Shadow(
                color: Colors.black,
                offset: Offset(-1, -1),
                blurRadius: 0,
              ),
              Shadow(color: Colors.black, offset: Offset(1, -1), blurRadius: 0),
              Shadow(color: Colors.black, offset: Offset(-1, 1), blurRadius: 0),
            ],
          ),
        ),
      ),
      position: Vector2(20, 50),
    );
    _scoreText.priority = 100;
    add(_scoreText);

    _bestScoreText = TextComponent(
      text: 'Best: $bestScore',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          textStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
              Shadow(color: Colors.black, offset: Offset(-1, 0), blurRadius: 0),
              Shadow(color: Colors.black, offset: Offset(0, -1), blurRadius: 0),
            ],
          ),
        ),
      ),
      position: Vector2(20, 90),
    );
    _bestScoreText.priority = 100;
    add(_bestScoreText);

    // Hide HUD initially — shown when game starts
    _scoreText.text = '';
    _bestScoreText.text = '';

    // Pause and show main menu
    pauseEngine();
    overlays.add('mainMenu');
  }

  // --- Multi-touch for Bullet Time ---
  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    _tappedPointers.add(pointerId);
    _updateBulletTime();
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    _tappedPointers.remove(pointerId);
    _updateBulletTime();
  }

  @override
  void onTapCancel(int pointerId) {
    _tappedPointers.remove(pointerId);
    _updateBulletTime();
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    _draggedPointers.add(pointerId);
    _updateBulletTime();
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (!paused && _gameStarted) {
      player.move(info.delta.global);
    }
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    _draggedPointers.remove(pointerId);
    _updateBulletTime();
  }

  @override
  void onDragCancel(int pointerId) {
    _draggedPointers.remove(pointerId);
    _updateBulletTime();
  }

  void _updateBulletTime() {
    if (currentMode == 'bullet_time' && _gameStarted && !paused) {
      final activeCount = _tappedPointers.union(_draggedPointers).length;
      bulletTimeActive = activeCount >= 2 && stamina > 0;
      timeDilation = bulletTimeActive ? 0.2 : 1.0;
      slowMoMultiplier = timeDilation;
    }
  }

  @override
  void update(double dt) {
    if (paused || !_gameStarted) return;
    super.update(dt);

    // Bullet Time stamina management
    if (currentMode == 'bullet_time') {
      if (bulletTimeActive) {
        stamina -= dt * 0.3;
        if (stamina <= 0) {
          stamina = 0;
          bulletTimeActive = false;
          timeDilation = 1.0;
          slowMoMultiplier = 1.0;
        }
      } else {
        // Recharge when not active
        stamina = (stamina + dt * 0.03).clamp(0.0, 1.0);
      }
    }

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
      if (currentMode == 'bullet_time') {
        _spawnInterval = max(0.1, _spawnInterval - 0.1);
        _brickSpeed += 40.0;
      } else {
        _spawnInterval = max(0.5, _spawnInterval - 0.2);
        _brickSpeed += 50.0;
      }
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      if (coinRushActive) {
        _spawnCoin();
      } else {
        _spawnBrick();
      }
    }

    // --- Coin Rush logic (Classic mode only) ---
    if (currentMode == 'classic') {
      // Speed boost at score >= 100
      if (score >= 100 && !_speedBoosted) {
        _speedBoosted = true;
        _brickSpeed *= 1.2;
        add(
          FloatingText(
            text: 'SPEED UP!',
            position: Vector2(size.x / 2 - 50, size.y / 2 - 60),
            floatSpeed: 60.0,
          ),
        );
      }

      // Random 5% chance every 5s to trigger Coin Rush
      if (score >= 100 && !coinRushActive) {
        _coinRushCheckTimer += dt;
        if (_coinRushCheckTimer >= 5.0) {
          _coinRushCheckTimer = 0;
          if (Random().nextDouble() < 0.05) {
            coinRushActive = true;
            _coinRushTimer = 7.0;
            add(
              FloatingText(
                text: 'COIN RUSH!',
                position: Vector2(size.x / 2 - 60, size.y / 2),
                floatSpeed: 40.0,
                lifespan: 2.0,
              ),
            );
          }
        }
      }

      // Coin Rush countdown
      if (coinRushActive) {
        _coinRushTimer -= dt;
        if (_coinRushTimer <= 0) {
          coinRushActive = false;
          _coinRushCheckTimer = 0;
        }
      }
    }

    // --- Gravity Flip logic ---
    if (currentMode == 'gravity_flip') {
      _gravityFlipTimer += dt;
      if (_gravityFlipTimer >= 10.0) {
        _gravityFlipTimer = 0;
        gravityDirection.y *= -1;
        add(
          FloatingText(
            text: 'GRAVITY FLIP!',
            position: Vector2(size.x / 2 - 70, size.y / 2),
            floatSpeed: 60.0,
            lifespan: 1.5,
          ),
        );
        // Camera scale effect for true visual flip
        try {
          if (gravityDirection.y < 0) {
            camera.viewfinder.transform.scale = Vector2(1, -1);
            camera.viewfinder.position = Vector2(0, size.y);
          } else {
            camera.viewfinder.transform.scale = Vector2(1, 1);
            camera.viewfinder.position = Vector2.zero();
          }
        } catch (_) {}
      }
    }

    // Lava mode: "camera follow" via shifting everything down, scoring, and procedural generation
    if (currentMode == 'lava') {
      final targetPlayerY = size.y * 0.6; // Keep player in lower half
      if (player.position.y < targetPlayerY) {
        final diff = targetPlayerY - player.position.y;

        player.position.y += diff;
        _highestPlatformY += diff;
        _distanceClimbed += diff;

        for (final b in children.whereType<SafeBrick>()) b.position.y += diff;
        for (final b in children.whereType<Brick>()) b.position.y += diff;
        for (final c in children.whereType<Coin>()) c.position.y += diff;
        for (final p in children.whereType<PowerUp>()) p.position.y += diff;
        for (final c in children.whereType<Cloud>()) c.position.y += diff;
        for (final f in children.whereType<FloatingText>())
          f.position.y += diff;
        for (final l in children.whereType<Lava>()) l.position.y += diff;
        for (final g in children.whereType<Ground>()) g.position.y += diff;
        for (final t in children.whereType<PixelTree>()) t.position.y += diff;
      }

      // Height-based scoring
      final newScore = (_distanceClimbed / 50).floor();
      if (newScore > score) {
        score = newScore;
        _scoreText.text = 'Score: $score (${scoreMultiplier}x)';
        if (score > bestScore) {
          bestScore = score;
          _bestScoreText.text = 'Best: $bestScore';
        }

        // Increase lava speed as score goes up
        for (final l in children.whereType<Lava>()) {
          l.riseSpeed = 15.0 + (score * 2.0);
        }
      }

      // Procedural platform generation
      _spawnPeriodicPlatforms();
    }
  }

  void _spawnPeriodicPlatforms() {
    // Spawn platforms if we are close to the top of the viewport (which is y=0)
    while (_highestPlatformY > -size.y) {
      // Guaranteed reachable distance: 50 to 100 pixels
      _highestPlatformY -= 50.0 + Random().nextDouble() * 50.0;

      final randomX = Random().nextDouble() * (size.x - 70);
      final safeBrick = SafeBrick(
        position: Vector2(randomX, _highestPlatformY),
        speed: 0,
      );
      add(safeBrick);

      // 5% chance to spawn a stationary hazard brick mid-air
      if (Random().nextDouble() < 0.05) {
        final brickX = Random().nextDouble() * (size.x - 60);
        final brick = Brick(
          position: Vector2(brickX, _highestPlatformY - 60), // Halfway up
          speed: 0,
        );
        add(brick);
      }
    }
  }

  void _spawnBrick() {
    final random = Random();
    final brickWidth = 60.0;
    final brickHeight = 25.0;

    // Random X between 0 and (screenWidth - brickWidth)
    final randomX = random.nextDouble() * (size.x - brickWidth);

    double startY = -brickHeight;
    // Alter spawn logic when gravity is flipped
    if (currentMode == 'gravity_flip' && gravityDirection.y < 0) {
      startY = size.y + brickHeight;
    }

    final brick = Brick(position: Vector2(randomX, startY), speed: _brickSpeed);
    add(brick);

    // 5% chance to spawn a power-up alongside a brick
    if (random.nextDouble() < 0.05) {
      _spawnPowerUp();
    }
  }

  void _spawnCoin() {
    final random = Random();
    final coinSize = 20.0;
    final randomX = random.nextDouble() * (size.x - coinSize);
    double startY = -coinSize;
    if (currentMode == 'gravity_flip' && gravityDirection.y < 0) {
      startY = size.y + coinSize;
    }

    final coin = Coin(
      position: Vector2(randomX, startY),
      speed: _brickSpeed * 0.8, // Coins fall slightly slower than bricks
    );
    add(coin);
  }

  void _spawnPowerUp({PowerUpType? forceType}) {
    final random = Random();
    final type =
        forceType ??
        PowerUpType.values[random.nextInt(PowerUpType.values.length)];

    // Random X between 0 and (screenWidth - 30)
    final randomX = random.nextDouble() * (size.x - 30);

    double startY = -30.0;
    if (currentMode == 'gravity_flip' && gravityDirection.y < 0) {
      startY = size.y + 30.0;
    }

    final powerUp = PowerUp(
      position: Vector2(randomX, startY),
      baseSpeed: 150.0,
      type: type,
    );
    add(powerUp);
  }

  void brickDodged(Brick brick) {
    comboCounter++;
    if (comboCounter >= 10) {
      scoreMultiplier++;
      comboCounter = 0;
      add(
        FloatingText(
          text:
              'Combo $scoreMultiplier'
              'x!',
          position: Vector2(size.x / 2 - 40, size.y / 2),
          floatSpeed: 80.0,
        ),
      );
    }

    int points = 1 * scoreMultiplier;
    if (brick.triggeredNearMiss) {
      points += 5 * scoreMultiplier;
      add(
        FloatingText(
          text: 'Close! +${5 * scoreMultiplier}',
          position: Vector2(player.position.x, player.position.y - 40),
        ),
      );
    }

    if (currentMode != 'lava') {
      score += points;
      _scoreText.text = 'Score: $score (${scoreMultiplier}x)';
      if (score > bestScore) {
        bestScore = score;
        _bestScoreText.text = 'Best: $bestScore';
      }
    }

    // --- Size Matters: grow player ---
    if (currentMode == 'size_matters') {
      if (player.scale.x < 3.0) {
        player.scale += Vector2.all(0.05);
      }

      // Giant Mode at 3.0x
      if (player.scale.x >= 3.0 && !_giantModeTriggered) {
        _giantModeTriggered = true;
        add(
          FloatingText(
            text: 'GIANT MODE!',
            position: Vector2(size.x / 2 - 60, size.y / 2 - 40),
            floatSpeed: 60.0,
          ),
        );
        // Screen shake
        try {
          (camera as dynamic).viewfinder.add(
            MoveEffect.by(
              Vector2(8, 8),
              EffectController(duration: 0.1, alternate: true, repeatCount: 3),
            ),
          );
        } catch (_) {}
      }

      // Spawn Shrink Pill every 20 points
      final nextThreshold = _lastShrinkPillScore + 20;
      if (score >= nextThreshold) {
        _lastShrinkPillScore = (score ~/ 20) * 20;
        _spawnPowerUp(forceType: PowerUpType.shrink);
      }
    }
  }

  /// Collect a coin during Coin Rush — increment wallet and persist.
  void collectCoin() {
    walletCoins++;
    gameData.totalCoins = walletCoins;
    storage.saveWallet(gameData);
    add(
      FloatingText(
        text: '+1 COIN',
        position: Vector2(player.position.x, player.position.y - 30),
        floatSpeed: 80.0,
      ),
    );
  }

  void collectPowerUp(PowerUpType type) {
    if (type == PowerUpType.shield) {
      player.hasShield = true;
    } else if (type == PowerUpType.slowMo) {
      if (currentMode != 'bullet_time') {
        slowMoMultiplier = 0.5;
        Future.delayed(const Duration(seconds: 5), () {
          if (currentMode != 'bullet_time') slowMoMultiplier = 1.0;
        });
      }
    } else if (type == PowerUpType.shrink) {
      if (currentMode == 'size_matters') {
        // In Size Matters, shrink pill incrementally reduces size
        player.scale -= Vector2.all(0.1);
        if (player.scale.x < 1.0) player.scale = Vector2.all(1.0);

        // Reset giant mode triggered flag if we shrank below 3.0
        if (player.scale.x < 3.0) _giantModeTriggered = false;

        add(
          FloatingText(
            text: 'Shrunk!',
            position: Vector2(player.position.x, player.position.y - 30),
          ),
        );
      } else {
        player.activateShrink();
      }
    }
  }

  /// Called from overlay when a mode is selected.
  void startGame(String mode) {
    currentMode = mode;
    bestScore = storage.getHighScore(mode);

    _resetScenery();

    // Clear existing entities
    children.whereType<Brick>().forEach((b) => b.removeFromParent());
    children.whereType<Cloud>().forEach((c) => c.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    children.whereType<FloatingText>().forEach((f) => f.removeFromParent());
    children.whereType<Coin>().forEach((c) => c.removeFromParent());
    children.whereType<SafeBrick>().forEach((s) => s.removeFromParent());
    if (_lava != null) {
      _lava!.removeFromParent();
      _lava = null;
    }

    // Reset state
    score = 0;
    if (mode == 'bullet_time') {
      _spawnInterval = 0.8;
      _brickSpeed = 350.0;
    } else if (mode == 'lava') {
      _spawnInterval = 5.0; // Very rare
      _brickSpeed = 200.0;
    } else {
      _spawnInterval = 2.0;
      _brickSpeed = 200.0;
    }
    _spawnTimer = 0;
    _cloudSpawnTimer = 0;
    _difficultyTimer = 0;
    slowMoMultiplier = 1.0;
    comboCounter = 0;
    scoreMultiplier = 1;
    _stationaryTimer = 0;
    player.scale = Vector2.all(1.0);
    if (mode == 'lava') {
      // Start higher in lava mode so player falls onto the initial green brick
      player.position = Vector2(size.x / 2, size.y - _groundHeight - 40);
    } else {
      player.position = Vector2(size.x / 2, size.y - _groundHeight);
    }
    player.resetJump();

    _highestPlatformY = player.position.y - 100;
    _distanceClimbed = 0;
    camera.viewfinder.position = Vector2.zero();

    // Reset Bullet Time state
    stamina = 1.0;
    bulletTimeActive = false;
    timeDilation = 1.0;
    _tappedPointers.clear();
    _draggedPointers.clear();

    // Reset Size Matters state
    _lastShrinkPillScore = 0;
    _giantModeTriggered = false;

    // Reset Coin Rush state
    coinRushActive = false;
    _coinRushTimer = 0;
    _coinRushCheckTimer = 0;
    _speedBoosted = false;

    // Reset Gravity Flip state
    gravityDirection = Vector2(0, 1);
    _gravityFlipTimer = 0;
    try {
      camera.viewfinder.angle = 0;
    } catch (_) {}

    // Reload wallet
    gameData = storage.loadGameData();
    walletCoins = gameData.totalCoins;

    // Show HUD
    _scoreText.text = 'Score: 0';
    _bestScoreText.text = 'Best: $bestScore';

    _gameStarted = true;
    navigateTo(null); // clear all overlays for gameplay
    resumeEngine();

    // Spawn lava if lava mode
    if (mode == 'lava') {
      _lava = Lava(riseSpeed: 15.0);
      add(_lava!);
      // Spawn a starting safe brick squarely under the player
      add(
        SafeBrick(
          position: Vector2(size.x / 2 - 40, size.y - _groundHeight + 10),
          speed: 0,
        )..size = Vector2(80, 20),
      );
    }
  }

  void gameOver() {
    pauseEngine();
    _gameStarted = false;
    bulletTimeActive = false;
    timeDilation = 1.0;
    slowMoMultiplier = 1.0;
    _tappedPointers.clear();
    _draggedPointers.clear();
    storage.updateHighScoreIfBetter(currentMode, score);
    // Save wallet on game over
    gameData.totalCoins = walletCoins;
    storage.saveWallet(gameData);
    if (score > bestScore) {
      bestScore = score;
    }
    // Hide HUD so it doesn't bleed through the Game Over overlay
    _scoreText.text = '';
    _bestScoreText.text = '';
    navigateTo('GameOver');
  }

  void returnToMainMenu() {
    _resetScenery();

    // Clear entities
    children.whereType<Brick>().forEach((b) => b.removeFromParent());
    children.whereType<Cloud>().forEach((c) => c.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    children.whereType<FloatingText>().forEach((f) => f.removeFromParent());
    children.whereType<Coin>().forEach((c) => c.removeFromParent());
    children.whereType<SafeBrick>().forEach((s) => s.removeFromParent());
    if (_lava != null) {
      _lava!.removeFromParent();
      _lava = null;
    }

    _gameStarted = false;
    score = 0;
    _scoreText.text = '';
    _bestScoreText.text = '';

    player.hasShield = false;
    player.scale = Vector2.all(1.0);
    player.position = Vector2(size.x / 2, size.y - _groundHeight);
    player.resetJump();

    // Reset mode-specific state
    stamina = 1.0;
    bulletTimeActive = false;
    timeDilation = 1.0;
    _tappedPointers.clear();
    _draggedPointers.clear();
    _lastShrinkPillScore = 0;
    _giantModeTriggered = false;
    slowMoMultiplier = 1.0;
    coinRushActive = false;
    _coinRushTimer = 0;
    _coinRushCheckTimer = 0;
    _speedBoosted = false;
    gravityDirection = Vector2(0, 1);
    _gravityFlipTimer = 0;
    try {
      camera.viewfinder.angle = 0;
    } catch (_) {}

    navigateTo('mainMenu');
    // Keep engine paused
  }

  void resetGame() {
    _resetScenery();

    // Remove all bricks, clouds, and power-ups
    children.whereType<Brick>().forEach((brick) => brick.removeFromParent());
    children.whereType<Cloud>().forEach((cloud) => cloud.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    children.whereType<Coin>().forEach((c) => c.removeFromParent());
    children.whereType<SafeBrick>().forEach((s) => s.removeFromParent());
    if (_lava != null) {
      _lava!.removeFromParent();
      _lava = null;
    }

    score = 0;
    _scoreText.text = 'Score: 0';
    _spawnTimer = 0;
    if (currentMode == 'bullet_time') {
      _spawnInterval = 0.8;
      _brickSpeed = 350.0;
    } else if (currentMode == 'lava') {
      _spawnInterval = 15.0; // Extremely rare
      _brickSpeed = 200.0;
    } else {
      _spawnInterval = 2.0;
      _brickSpeed = 200.0;
    }
    _cloudSpawnTimer = 0;
    _difficultyTimer = 0;
    slowMoMultiplier = 1.0;

    // Reset camera from gravity flip
    gravityDirection = Vector2(0, 1);
    camera.viewfinder.transform.scale = Vector2(1, 1);
    camera.viewfinder.position = Vector2.zero();

    player.hasShield = false;

    comboCounter = 0;
    scoreMultiplier = 1;
    _stationaryTimer = 0;

    // Reset Bullet Time state
    stamina = 1.0;
    bulletTimeActive = false;
    timeDilation = 1.0;
    _tappedPointers.clear();
    _draggedPointers.clear();

    // Reset Size Matters state
    _lastShrinkPillScore = 0;
    _giantModeTriggered = false;

    // Reset Coin Rush state
    coinRushActive = false;
    _coinRushTimer = 0;
    _coinRushCheckTimer = 0;
    _speedBoosted = false;

    // Reset Gravity Flip state
    gravityDirection = Vector2(0, 1);
    _gravityFlipTimer = 0;
    try {
      camera.viewfinder.angle = 0;
    } catch (_) {}

    // Reset player position
    player.scale = Vector2.all(1.0);
    if (currentMode == 'lava') {
      player.position = Vector2(size.x / 2, size.y - _groundHeight - 40);
    } else {
      player.position = Vector2(size.x / 2, size.y - _groundHeight);
    }
    player.resetJump();

    _highestPlatformY = player.position.y - 100;
    _distanceClimbed = 0;
    camera.viewfinder.position = Vector2.zero();

    _gameStarted = true;
    navigateTo(null); // clear all overlays, back to gameplay
    resumeEngine();

    // Re-spawn lava if lava mode
    if (currentMode == 'lava') {
      _lava = Lava(riseSpeed: 15.0);
      add(_lava!);
      // Spawn a starting safe brick squarely under the player
      add(
        SafeBrick(
          position: Vector2(size.x / 2 - 40, size.y - _groundHeight + 10),
          speed: 0,
        )..size = Vector2(80, 20),
      );
    }
  }

  void _resetScenery() {
    final floatGroundY = size.y - _groundHeight;
    for (final ground in children.whereType<Ground>()) {
      ground.position.y = floatGroundY;
    }
    final treeY = floatGroundY - 70;
    int treeIndex = 0;
    for (final tree in children.whereType<PixelTree>()) {
      if (treeIndex == 0)
        tree.position.y = treeY;
      else if (treeIndex == 1)
        tree.position.y = treeY - 10;
      else if (treeIndex == 2)
        tree.position.y = treeY + 5;
      treeIndex++;
    }
  }
}
