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
    final box = Hive.box<GameConfig>('game_configs');

    if (box.isEmpty) {
      _initializeDefaultConfigs();
    } else {
      state = box.values.toList();
    }
  }

  Future<void> _initializeDefaultConfigs() async {
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
      if (newScore > state[configIndex].highScore) {
        state[configIndex].highScore = newScore;
        await updateGameConfig(state[configIndex]);
        // Trigger state update to notify listeners
        state = [...state];
        print('Updated high score for $gameId: $newScore'); // Debug log
      } else {
        print(
            'Score $newScore not higher than current best ${state[configIndex].highScore} for $gameId'); // Debug log
      }
    } else {
      print('Config not found for $gameId'); // Debug log
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
