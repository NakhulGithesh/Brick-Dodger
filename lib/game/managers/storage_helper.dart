import 'package:shared_preferences/shared_preferences.dart';

import 'game_data.dart';

/// Helper class for persistent storage of coins and per-mode high scores.
class StorageHelper {
  static const String _totalCoinsKey = 'totalCoins';
  static const String _highScorePrefix = 'bestScore_';

  static final List<String> gameModes = [
    'classic',
    'gravity_flip',
    'the_floor_is_lava',
    'bullet_time',
    'size_matters',
    'invisible_bricks',
  ];

  static final Map<String, String> modeDisplayNames = {
    'classic': 'Classic',
    'gravity_flip': 'Gravity Flip',
    'the_floor_is_lava': 'The Floor Is Lava',
    'bullet_time': 'Bullet Time',
    'size_matters': 'Size Matters',
    'invisible_bricks': 'Invisible Bricks',
  };

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'StorageHelper not initialized. Call init() first.');
    return _prefs!;
  }

  // --- Coins ---

  int getTotalCoins() => _p.getInt(_totalCoinsKey) ?? 0;

  Future<void> setTotalCoins(int coins) async {
    await _p.setInt(_totalCoinsKey, coins);
  }

  Future<void> addCoins(int amount) async {
    await setTotalCoins(getTotalCoins() + amount);
  }

  // --- High Scores ---

  int getHighScore(String mode) => _p.getInt('$_highScorePrefix$mode') ?? 0;

  Future<void> setHighScore(String mode, int score) async {
    await _p.setInt('$_highScorePrefix$mode', score);
  }

  /// Updates high score only if the new score is higher. Returns true if updated.
  Future<bool> updateHighScoreIfBetter(String mode, int score) async {
    final current = getHighScore(mode);
    if (score > current) {
      await setHighScore(mode, score);
      return true;
    }
    return false;
  }

  /// Returns a map of mode key -> high score for all modes.
  Map<String, int> getAllHighScores() {
    final scores = <String, int>{};
    for (final mode in gameModes) {
      scores[mode] = getHighScore(mode);
    }
    return scores;
  }

  // --- GameData / Wallet ---

  /// Save full game data (wallet, power-up multipliers, skins).
  Future<void> saveWallet(GameData data) async {
    await data.save(_p);
  }

  /// Load game data from persistent storage.
  GameData loadGameData() {
    return GameData.load(_p);
  }
}
