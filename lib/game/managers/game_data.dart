import 'package:shared_preferences/shared_preferences.dart';

/// Holds game-wide persistent data for the shop and progression systems.
class GameData {
  int totalCoins;
  double powerUpDurationMultiplier;
  List<String> unlockedSkins;

  GameData({
    this.totalCoins = 0,
    this.powerUpDurationMultiplier = 1.0,
    List<String>? unlockedSkins,
  }) : unlockedSkins = unlockedSkins ?? ['default'];

  /// Save to SharedPreferences.
  Future<void> save(SharedPreferences prefs) async {
    await prefs.setInt('totalCoins', totalCoins);
    await prefs.setDouble('powerUpDurationMultiplier', powerUpDurationMultiplier);
    await prefs.setStringList('unlockedSkins', unlockedSkins);
  }

  /// Load from SharedPreferences with sensible defaults.
  factory GameData.load(SharedPreferences prefs) {
    return GameData(
      totalCoins: prefs.getInt('totalCoins') ?? 0,
      powerUpDurationMultiplier:
          prefs.getDouble('powerUpDurationMultiplier') ?? 1.0,
      unlockedSkins: prefs.getStringList('unlockedSkins') ?? ['default'],
    );
  }
}
