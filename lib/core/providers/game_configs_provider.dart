import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/models.dart';

final gameConfigsProvider =
    StateNotifierProvider<GameConfigsNotifier, List<GameConfig>>((ref) {
  return GameConfigsNotifier();
});

class GameConfigsNotifier extends StateNotifier<List<GameConfig>> {
  GameConfigsNotifier() : super([]) {
    _loadConfigs();
  }

  void _loadConfigs() {
    try {
      final box = Hive.box<GameConfig>('game_configs');

      if (box.isEmpty) {
        _initializeDefaultConfigs();
      } else {
        state = box.values.toList();
      }
    } catch (e) {
      // If there's an error loading configs, initialize defaults
      _initializeDefaultConfigs();
    }
  }

  Future<void> _initializeDefaultConfigs() async {
    try {
      final box = Hive.box<GameConfig>('game_configs');
      final configs = <GameConfig>[];

      for (final gameId in GameId.values) {
        final config = GameConfig(
          gameId: gameId,
          unlocked: true,
          difficultyRating: 1200.0,
          highScore: 0.0,
        );
        await box.add(config);
        configs.add(config);
      }

      state = configs;
    } catch (e) {
      // If there's an error initializing, create minimal state
      final configs = <GameConfig>[];
      for (final gameId in GameId.values) {
        configs.add(GameConfig(
          gameId: gameId,
          unlocked: true,
          difficultyRating: 1200.0,
          highScore: 0.0,
        ));
      }
      state = configs;
    }
  }

  Future<void> updateGameConfig(GameConfig config) async {
    await config.save();
    state = [...state];
  }

  Future<void> updateDifficulty(GameId gameId, double newRating) async {
    final configIndex = state.indexWhere((c) => c.gameId == gameId);
    if (configIndex != -1) {
      state[configIndex].difficultyRating = newRating;
      await updateGameConfig(state[configIndex]);
      // Trigger state update to notify listeners
      state = [...state];
    }
  }

  Future<void> updateHighScore(GameId gameId, double newScore) async {
    final configIndex = state.indexWhere((c) => c.gameId == gameId);
    if (configIndex != -1) {
      bool shouldUpdate = false;

      // For Speed Tap, lower reaction time is better
      if (gameId == GameId.speedTap) {
        // Only update if this is the first score (highScore == 0) or if new time is better (lower)
        shouldUpdate = state[configIndex].highScore == 0 ||
            newScore < state[configIndex].highScore;
      } else {
        // For all other games, higher score is better
        shouldUpdate = newScore > state[configIndex].highScore;
      }

      if (shouldUpdate) {
        state[configIndex].highScore = newScore;
        await updateGameConfig(state[configIndex]);
        // Trigger state update to notify listeners
        state = [...state];
        // High score updated successfully
      } else {
        // Score not better than current best
      }
    } else {
      // Config not found for gameId
    }
  }

  GameConfig? getConfig(GameId gameId) {
    try {
      return state.firstWhere((c) => c.gameId == gameId);
    } catch (e) {
      return null;
    }
  }
}
